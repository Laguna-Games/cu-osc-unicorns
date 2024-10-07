// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibIdempotence} from "../libraries/LibIdempotence.sol";
import {LibRNG} from "../../lib/cu-osc-common/src/libraries/LibRNG.sol";
import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibPermissions} from "./LibPermissions.sol";
import {LibStatCache} from "./LibStatCache.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";

/// @custom:storage-location erc7201:games.laguna.libEvolution
library LibEvolution {
    event EvolutionRNGRequested(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed playerWallet
    );
    event EvolutionRNGRequestedV2(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed owner,
        address playerWallet
    );
    event EvolutionReadyForTokenURI(
        uint256 indexed roundTripId,
        address indexed playerWallet
    );
    event EvolutionReadyForTokenURIV2(
        uint256 indexed roundTripId,
        address indexed owner,
        address indexed playerWallet
    );
    event EvolutionComplete(
        uint256 indexed roundTripId,
        address indexed playerWallet
    );
    event EvolutionCompleteV2(
        uint256 indexed roundTripId,
        address indexed owner,
        address indexed playerWallet
    );

    uint256 private constant SALT_11 = 11;
    uint256 private constant SALT_12 = 12;
    uint256 private constant SALT_13 = 13;
    uint256 private constant SALT_14 = 14;
    uint256 private constant SALT_15 = 15;
    uint256 private constant SALT_16 = 16;

    uint256 private constant SALT_21 = 21;
    uint256 private constant SALT_22 = 22;
    uint256 private constant SALT_23 = 23;
    uint256 private constant SALT_24 = 24;
    uint256 private constant SALT_25 = 25;
    uint256 private constant SALT_26 = 26;

    uint256 private constant SALT_31 = 31;
    uint256 private constant SALT_32 = 32;
    uint256 private constant SALT_33 = 33;
    uint256 private constant SALT_34 = 34;
    uint256 private constant SALT_35 = 35;
    uint256 private constant SALT_36 = 36;

    string private constant CALLBACK_SIGNATURE =
        "fulfillEvolutionRandomness(uint256,uint256[])";

    //  @dev Storage slot for Evolution Storage
    bytes32 private constant EVOLUTION_STORAGE_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.libEvolution")) - 1)
        ) & ~bytes32(uint256(0xff));

    struct LibEvolutionStorage {
        mapping(uint256 vrfRequestId => uint256 blockDeadline) blockDeadlineByVRFRequestId;
        mapping(uint256 roundTripId => uint256 vrfRequestId) roundTripIdByVRFRequestId;
        mapping(uint256 roundTripId => uint256 vrfRequestId) vrfRequestIdByRoundTripId;
        mapping(uint256 vrfRequestId => uint256 tokenId) tokenIdByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 booster) upgradeBoosterByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 randomness) rngByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 rngBlockNumber) rngBlockNumberByVRFRequestId;
        mapping(uint256 tokenId => uint256 roundTripId) roundTripIdByTokenId;
    }

    function beginEvolution(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 ttlBlock,
        uint256 upgradeBooster
    ) internal {
        validateBeginEvolution(tokenId, ttlBlock);
        uint256 vrfRequestId = LibRNG.requestRandomness(CALLBACK_SIGNATURE);
        completeBeginEvolution(
            roundTripId,
            tokenId,
            ttlBlock,
            upgradeBooster,
            vrfRequestId
        );
    }

    function completeBeginEvolution(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 ttlBlock,
        uint256 upgradeBooster,
        uint256 vrfRequestId
    ) private {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        saveDataOnEvolutionStruct(
            vrfRequestId,
            roundTripId,
            ttlBlock,
            tokenId,
            upgradeBooster
        );
        LibIdempotence._setEvolutionStarted(tokenId, true);
        emit EvolutionRNGRequested(
            roundTripId,
            bytes32(vrfRequestId),
            erc721.owners[tokenId]
        );
        emit EvolutionRNGRequestedV2(
            roundTripId,
            bytes32(vrfRequestId),
            erc721.owners[tokenId],
            msg.sender
        );
    }

    function validateBeginEvolution(
        uint256 tokenId,
        uint256 ttlBlock
    ) private view {
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_EVOLVING_ALLOWED
        );
        uint256 dna = LibUnicornDNA._getDNA(tokenId);
        require(
            ttlBlock >=
                LibEnvironment.getBlockNumber() +
                    LibRNG.rngStorage().blocksToRespond,
            "Evolution: TTL has expired."
        );
        require(
            dna > 0,
            "Evolution: Cannot evolve a unicorn that doesnt exist or with invalid DNA"
        );
        LibUnicornDNA.enforceDNAVersionMatch(dna);

        require(
            LibUnicornDNA._getLifecycleStage(dna) ==
                LibUnicornDNA.LIFECYCLE_BABY,
            "Evolution: Unicorn must be baby to evolve"
        );
        require(
            !LibIdempotence._getHatchingRandomnessFulfilled(tokenId),
            "Evolution: Cannot begin evolution if hatching hasnt been completed"
        );
        require(
            !LibIdempotence._getEvolutionStarted(tokenId) &&
                !LibIdempotence._getEvolutionRandomnessFulfilled(tokenId),
            "Evolution: Baby cannot be evolving already to begin evolution"
        );
        require(
            LibUnicornDNA._getGameLocked(dna) == true,
            "Evolution: Unicorn must be locked to start evolving"
        );
    }

    function evolutionStorage()
        internal
        pure
        returns (LibEvolutionStorage storage les)
    {
        bytes32 position = EVOLUTION_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            les.slot := position
        }
    }

    function getVRFRequestId(
        uint256 roundTripId
    ) internal view returns (uint256) {
        return evolutionStorage().vrfRequestIdByRoundTripId[roundTripId];
    }

    function getRoundTripId(
        uint256 vrfRequestId
    ) internal view returns (uint256) {
        return evolutionStorage().roundTripIdByVRFRequestId[vrfRequestId];
    }

    function getRoundTripIdForToken(
        uint256 tokenId
    ) internal view returns (uint256) {
        return evolutionStorage().roundTripIdByTokenId[tokenId];
    }

    function getBlockDeadline(
        uint256 vrfRequestId
    ) internal view returns (uint256) {
        return evolutionStorage().blockDeadlineByVRFRequestId[vrfRequestId];
    }

    function getUpgradeBooster(
        uint256 vrfRequestId
    ) internal view returns (uint256) {
        return evolutionStorage().upgradeBoosterByVRFRequestId[vrfRequestId];
    }

    function getTokenId(uint256 vrfRequestId) internal view returns (uint256) {
        return evolutionStorage().tokenIdByVRFRequestId[vrfRequestId];
    }

    function setRandomness(uint256 vrfRequestId, uint256 randomness) internal {
        LibEvolutionStorage storage les = evolutionStorage();
        les.rngByVRFRequestId[vrfRequestId] = randomness;
        les.rngBlockNumberByVRFRequestId[vrfRequestId] = LibEnvironment
            .getBlockNumber();
    }

    function saveDataOnEvolutionStruct(
        uint256 vrfRequestId,
        uint256 roundTripId,
        uint256 blockDeadline,
        uint256 tokenId,
        uint256 upgradeBooster
    ) internal {
        LibEvolutionStorage storage les = evolutionStorage();
        les.blockDeadlineByVRFRequestId[vrfRequestId] = blockDeadline;
        les.roundTripIdByVRFRequestId[vrfRequestId] = roundTripId;
        les.tokenIdByVRFRequestId[vrfRequestId] = tokenId;
        les.upgradeBoosterByVRFRequestId[vrfRequestId] = upgradeBooster;
        les.vrfRequestIdByRoundTripId[roundTripId] = vrfRequestId;
        les.roundTripIdByTokenId[tokenId] = roundTripId;
    }

    function cleanUpRoundTrip(uint256 vrfRequestId) internal {
        LibEvolutionStorage storage les = evolutionStorage();
        uint256 roundTripId = les.roundTripIdByVRFRequestId[vrfRequestId];
        uint256 tokenId = les.tokenIdByVRFRequestId[vrfRequestId];
        delete les.blockDeadlineByVRFRequestId[vrfRequestId];
        delete les.roundTripIdByVRFRequestId[vrfRequestId];
        delete les.vrfRequestIdByRoundTripId[roundTripId];
        delete les.tokenIdByVRFRequestId[vrfRequestId];
        delete les.upgradeBoosterByVRFRequestId[vrfRequestId];
        delete les.roundTripIdByTokenId[tokenId];
        delete les.rngByVRFRequestId[vrfRequestId];
        delete les.rngBlockNumberByVRFRequestId[vrfRequestId];
    }

    function setIdempotenceForRandomnessFulfilled(uint256 tokenId) internal {
        LibIdempotence._setEvolutionStarted(tokenId, false);
        LibIdempotence._setEvolutionRandomnessFulfilled(tokenId, true);
    }

    function setIdempotenceForEvolutionFinished(uint256 tokenId) internal {
        LibIdempotence._setEvolutionRandomnessFulfilled(tokenId, false);
    }

    function evolutionFulfillRandomness(
        uint256 vrfRequestId,
        uint256 randomness
    ) internal {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        LibCheck.enforceBlockDeadlineIsValid(getBlockDeadline(vrfRequestId));
        uint256 tokenId = getTokenId(vrfRequestId);
        require(
            LibIdempotence._getEvolutionStarted(tokenId),
            "Evolution: Evolution has to be in STARTED state to fulfillRandomness"
        );

        LibRNG.rngStorage().rngNonce = randomness;

        setRandomness(vrfRequestId, randomness);
        setIdempotenceForRandomnessFulfilled(tokenId);
        setDNAForAdult(tokenId, getUpgradeBooster(vrfRequestId));
        LibUnicorn.unicornStorage().bioClock[tokenId] = block.timestamp;

        emit EvolutionReadyForTokenURI(
            getRoundTripId(vrfRequestId),
            erc721.owners[tokenId]
        );
        emit EvolutionReadyForTokenURIV2(
            getRoundTripId(vrfRequestId),
            erc721.owners[tokenId],
            msg.sender
        );
    }

    function setDNAForAdult(uint256 tokenId, uint256 upgradeBooster) internal {
        uint256 dna = attemptUpgradeOfEveryGene(tokenId, upgradeBooster);
        dna = LibUnicornDNA._setLifecycleStage(
            dna,
            LibUnicornDNA.LIFECYCLE_ADULT
        );
        dna = LibUnicornDNA._setBreedingPoints(
            dna,
            LibUnicornDNA.DEFAULT_BREEDING_POINTS
        );
        LibUnicornDNA._setDNA(tokenId, dna);
        LibStatCache.deleteCache(tokenId); //  we can't afford to update cache on the VRF callback...
    }

    function attemptUpgradeOfEveryGene(
        uint256 tokenId,
        uint256 upgradeBooster
    ) internal view returns (uint256 dna) {
        uint256 randomness = evolutionStorage().rngByVRFRequestId[
            getVRFRequestId(getRoundTripIdForToken(tokenId))
        ];
        dna = LibUnicornDNA._getDNA(tokenId);
        uint256 newGene;

        // major genes
        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getBodyMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_11)
        );
        dna = LibUnicornDNA._setBodyMajorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getFaceMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_12)
        );
        dna = LibUnicornDNA._setFaceMajorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHornMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_13)
        );
        dna = LibUnicornDNA._setHornMajorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHoovesMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_14)
        );
        dna = LibUnicornDNA._setHoovesMajorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getManeMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_15)
        );
        dna = LibUnicornDNA._setManeMajorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getTailMajorGene(dna),
            1,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_16)
        );
        dna = LibUnicornDNA._setTailMajorGene(dna, newGene);

        // mid genes
        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getBodyMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_21)
        );
        dna = LibUnicornDNA._setBodyMidGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getFaceMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_22)
        );
        dna = LibUnicornDNA._setFaceMidGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHornMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_23)
        );
        dna = LibUnicornDNA._setHornMidGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHoovesMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_24)
        );
        dna = LibUnicornDNA._setHoovesMidGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getManeMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_25)
        );
        dna = LibUnicornDNA._setManeMidGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getTailMidGene(dna),
            2,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_26)
        );
        dna = LibUnicornDNA._setTailMidGene(dna, newGene);

        // minor genes
        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getBodyMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_31)
        );
        dna = LibUnicornDNA._setBodyMinorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getFaceMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_32)
        );
        dna = LibUnicornDNA._setFaceMinorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHornMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_33)
        );
        dna = LibUnicornDNA._setHornMinorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getHoovesMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_34)
        );
        dna = LibUnicornDNA._setHoovesMinorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getManeMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_35)
        );
        dna = LibUnicornDNA._setManeMinorGene(dna, newGene);

        newGene = attemptGeneUpgrade(
            LibUnicornDNA._getTailMinorGene(dna),
            3,
            upgradeBooster,
            LibRNG.expand(10000, randomness, SALT_36)
        );
        dna = LibUnicornDNA._setTailMinorGene(dna, newGene);

        return dna;
    }

    function attemptGeneUpgrade(
        uint256 geneId,
        uint256 geneDominance,
        uint256 upgradeBooster,
        uint256 rand
    ) private view returns (uint256) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        if (gs.geneTierById[geneId] >= 6) return geneId;

        // geneUpgradeChances are percentages, while upgradeBooster is on a 10000 = 100% scale.
        uint256 baseUpgradeChance = (
            gs.geneUpgradeChances[gs.geneTierById[geneId]][geneDominance]
        ) * 100;

        if (
            baseUpgradeChance == 0 ||
            (rand > baseUpgradeChance + upgradeBooster)
        ) {
            return geneId;
        }

        return gs.geneTierUpgradeById[geneId];
    }

    function retryEvolution(uint256 roundTripId) internal {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        uint256 requestId = getVRFRequestId(roundTripId);
        uint256 tokenId = getTokenId(requestId);
        uint256 upgradeBooster = getUpgradeBooster(requestId);

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_EVOLVING_ALLOWED
        );
        require(
            !LibIdempotence._getEvolutionRandomnessFulfilled(tokenId) &&
                LibIdempotence._getEvolutionStarted(tokenId),
            "Evolution: Cannot retry evolution for this tokenId"
        );
        require(
            LibEnvironment.getBlockNumber() > getBlockDeadline(requestId),
            "Evolution: Cannot retry evolution if TTL has not expired yet"
        );

        LibRNG.rngStorage().rngNonce = LibRNG.getRuntimeRNG(type(uint256).max);

        setIdempotenceForRandomnessFulfilled(tokenId);
        uint256 randomness = LibRNG.getRuntimeRNG();
        setRandomness(requestId, randomness);
        setDNAForAdult(tokenId, upgradeBooster);
        LibUnicorn.unicornStorage().bioClock[tokenId] = block.timestamp;

        emit EvolutionReadyForTokenURI(roundTripId, erc721.owners[tokenId]);
        emit EvolutionReadyForTokenURIV2(
            roundTripId,
            erc721.owners[tokenId],
            msg.sender
        );
    }

    function finishEvolution(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 vrfRequestId,
        uint256 tokenId
    ) internal {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_EVOLVING_ALLOWED
        );

        require(
            LibIdempotence._getEvolutionRandomnessFulfilled(tokenId) &&
                !LibIdempotence._getEvolutionStarted(tokenId),
            "Evolution: Cannot finishEvolution if randomness hasnt been fulfilled yet."
        );

        LibERC721.setTokenURI(tokenId, tokenURI);
        setIdempotenceForEvolutionFinished(tokenId);

        LibStatCache.cacheNaturalStats(tokenId); //  Put the cache back...

        //  clean up workflow data:
        cleanUpRoundTrip(vrfRequestId);

        emit EvolutionComplete(roundTripId, erc721.owners[tokenId]);
        emit EvolutionCompleteV2(
            roundTripId,
            erc721.owners[tokenId],
            msg.sender
        );
    }
}
