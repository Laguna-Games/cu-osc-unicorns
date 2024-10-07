// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibPermissions} from "./LibPermissions.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibUnicornDNA} from "./LibUnicornDNA.sol";
import {LibIdempotence} from "./LibIdempotence.sol";
import {LibRNG} from "../../lib/cu-osc-common/src/libraries/LibRNG.sol";
import {LibUnicornNames} from "./LibUnicornNames.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {LibStatCache} from "./LibStatCache.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";

/// @custom:storage-location erc7201:games.laguna.cryptounicorns.LibBreeding
library LibBreeding {
    event BreedingStarted(
        uint256 indexed firstParentId,
        uint256 indexed secondParentId,
        address indexed breeder
    );
    event BreedingStartedV2(
        uint256 firstParentId,
        uint256 secondParentId,
        address indexed owner,
        address indexed breeder
    );
    event NewEggRNGRequested(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId
    );
    event NewEggRNGRequestedV2(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed owner
    );
    event NewEggReadyForTokenURI(
        uint256 indexed roundTripId,
        uint256 indexed eggId,
        address indexed playerWallet
    );
    event NewEggReadyForTokenURIV2(
        uint256 indexed roundTripId,
        uint256 indexed eggId,
        address indexed owner,
        address playerWallet
    );
    event BreedingComplete(uint256 indexed roundTripId, uint256 indexed eggId);
    event BreedingCompleteV2(
        uint256 indexed roundTripId,
        uint256 indexed eggId,
        address indexed owner
    );
    event UnicornEggCreated(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 indexed childId,
        address indexed breeder
    );
    event UnicornEggCreatedV2(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 indexed childId,
        address indexed owner,
        address indexed breeder
    );

    uint256 internal constant POSSIBLE_CLASS_0 = 0;
    uint256 internal constant POSSIBLE_CLASS_1 = 1;
    uint256 internal constant POSSIBLE_CLASS_2 = 2;
    uint256 internal constant CLASS_PROBABILITY_0 = 3;
    uint256 internal constant CLASS_PROBABILITY_1 = 4;
    uint256 internal constant CLASS_PROBABILITY_2 = 5;
    uint256 internal constant TTL_BLOCK = 6;
    uint256 internal constant EGG_ID = 7;

    string public constant CALLBACK_SIGNATURE =
        "fulfillBreedingRandomness(uint256,uint256[])";

    bytes32 private constant STORAGE_SLOT_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("games.laguna.cryptounicorns.LibBreeding")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    struct BreedingStorage {
        // requestId => the server requestId that asked for randomness
        mapping(uint256 vrfRequestId => uint256 roundTripId) roundTripIdByVRFRequestId;
        // transactionId => an array that represents breeding parameters
        mapping(uint256 roundTripId => uint256[8] params) breedingByRoundTripId;
    }

    function breedingStorage()
        internal
        pure
        returns (BreedingStorage storage bs)
    {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            bs.slot := position
        }
    }

    function createEggWithBasicDNA() internal returns (uint256) {
        uint256 eggId = LibERC721.mintNextToken(address(this));
        uint256 dna = 0;
        dna = LibUnicornDNA._setVersion(dna, LibUnicornDNA._targetDNAVersion());
        // This DNA parameters will have this values by default, so implicitly we are setting:
        // origin = false
        // limitedEdition = false;
        // breedingPoints = 0
        dna = LibUnicornDNA._setLifecycleStage(
            dna,
            LibUnicornDNA.LIFECYCLE_EGG
        );
        LibUnicornDNA._setDNA(eggId, dna);
        return eggId;
    }

    function enforceBeginBreedingIsValid(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 ttlBlock
    ) internal view {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        require(
            ttlBlock - LibEnvironment.getBlockNumber() >
                LibRNG.rngStorage().blocksToRespond,
            "Breeding: TTL has expired."
        );

        require(
            erc721.owners[firstParentId] == erc721.owners[secondParentId],
            "Breeding: both unicorns must belong to the same account."
        );
        enforceParentIdsInCorrectState(firstParentId, secondParentId);
        enforceClassesAndProbabilitiesAreCorrect(
            possibleClasses,
            classProbabilities
        );

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            firstParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            secondParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );
    }

    function enforceParentIdsInCorrectState(
        uint256 firstParentId,
        uint256 secondParentId
    ) private view {
        uint256 firstParentDNA = LibUnicornDNA._getDNA(firstParentId);
        uint256 secondParentDNA = LibUnicornDNA._getDNA(secondParentId);
        LibUnicornDNA.enforceDNAVersionMatch(firstParentDNA);
        LibUnicornDNA.enforceDNAVersionMatch(secondParentDNA);
        require(
            LibUnicornDNA._getLifecycleStage(firstParentDNA) ==
                LibUnicornDNA.LIFECYCLE_ADULT &&
                LibUnicornDNA._getLifecycleStage(secondParentDNA) ==
                LibUnicornDNA.LIFECYCLE_ADULT,
            "Breeding: Unicorns must be adults to breed"
        );
        require(
            LibUnicornDNA._getGameLocked(firstParentDNA) &&
                LibUnicornDNA._getGameLocked(secondParentDNA),
            "Breeding: Unicorns must be locked into the game to breed"
        );
        require(
            firstParentId != secondParentId,
            "Breeding: Cannot breed unicorn with itself"
        );
        require(
            !LibIdempotence._getParentIsBreeding(firstParentId) &&
                !LibIdempotence._getParentIsBreeding(secondParentId),
            "Breeding: Cannot breed unicorns that are breeding already"
        );
    }

    function enforceClassesAndProbabilitiesAreCorrect(
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities
    ) private pure {
        require(
            possibleClasses.length == 3,
            "Breeding: Exactly 3 classes possible should be provided"
        );
        require(
            classProbabilities.length == possibleClasses.length,
            "Breeding: Class probabilities should be the same length as possible classes"
        );
        require(
            classProbabilities[0] +
                classProbabilities[1] +
                classProbabilities[2] >=
                2,
            "Breeding: Missing class probabilities"
        );
    }

    function saveDataOnBreedingStruct(
        uint256 roundTripId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 ttlBlock,
        uint256 eggId
    ) private {
        uint256[8] storage breeding = breedingStorage().breedingByRoundTripId[
            roundTripId
        ];
        breeding[POSSIBLE_CLASS_0] = possibleClasses[0];
        breeding[POSSIBLE_CLASS_1] = possibleClasses[1];
        breeding[POSSIBLE_CLASS_2] = possibleClasses[2];
        breeding[CLASS_PROBABILITY_0] = classProbabilities[0];
        breeding[CLASS_PROBABILITY_1] = classProbabilities[1];
        breeding[CLASS_PROBABILITY_2] = classProbabilities[2];
        breeding[TTL_BLOCK] = ttlBlock;
        breeding[EGG_ID] = eggId;
    }

    function beginBreeding(
        uint256 roundTripId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 ttlBlock,
        uint256 eggId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 owedRBW,
        uint256 owedUNIM
    ) internal {
        uint256 vrfRequestId = LibRNG.requestRandomness(CALLBACK_SIGNATURE);
        handleBeginBreedingDataAndDNA(
            roundTripId,
            possibleClasses,
            classProbabilities,
            ttlBlock,
            eggId,
            firstParentId,
            secondParentId,
            vrfRequestId
        );
        address nftOwner = LibERC721.ownerOf(firstParentId);
        IERC20(LibResourceLocator.cuToken()).transferFrom(
            nftOwner,
            LibResourceLocator.gameBank(),
            owedRBW
        );
        IERC20(LibResourceLocator.unimToken()).transferFrom(
            nftOwner,
            LibResourceLocator.gameBank(),
            owedUNIM
        );
        emit NewEggRNGRequested(roundTripId, bytes32(vrfRequestId));
        emit NewEggRNGRequestedV2(roundTripId, bytes32(vrfRequestId), nftOwner);
    }

    function handleBeginBreedingDataAndDNA(
        uint256 roundTripId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 ttlBlock,
        uint256 eggId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 vrfRequestId
    ) private {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();

        saveDataOnBreedingStruct(
            roundTripId,
            possibleClasses,
            classProbabilities,
            ttlBlock,
            eggId
        );

        subtractABreedingPoint(firstParentId);
        subtractABreedingPoint(secondParentId);

        us.unicornParents[eggId][0] = firstParentId;
        us.unicornParents[eggId][1] = secondParentId;

        setIdempotenceForBeginBreeding(firstParentId, secondParentId, eggId);
        emit BreedingStarted(firstParentId, secondParentId, msg.sender);
        emit BreedingStartedV2(
            firstParentId,
            secondParentId,
            LibERC721.erc721Storage().owners[firstParentId],
            msg.sender
        );

        breedingStorage().roundTripIdByVRFRequestId[vrfRequestId] = roundTripId;
    }

    function subtractABreedingPoint(uint256 parentId) internal {
        uint256 parentDna = LibUnicornDNA._getDNA(parentId);
        uint256 breedingPoints = LibUnicornDNA._getBreedingPoints(parentDna);
        require(
            breedingPoints > 0,
            "Breeding: Cannot breed a unicorn with 0 breeding points"
        );
        parentDna = LibUnicornDNA._setBreedingPoints(
            parentDna,
            breedingPoints - 1
        );
        LibUnicornDNA._setDNA(parentId, parentDna);
        LibStatCache.updateBreedingPoints(parentId, breedingPoints);
    }

    function setIdempotenceForBeginBreeding(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 eggId
    ) private {
        LibIdempotence._setParentIsBreeding(firstParentId, true);
        LibIdempotence._setParentIsBreeding(secondParentId, true);
        LibIdempotence._setNewEggWaitingForRNG(eggId, true);
    }

    function retryBreeding(uint256 roundTripId) internal {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        BreedingStorage storage bs = breedingStorage();

        uint256[8] storage breeding = bs.breedingByRoundTripId[roundTripId];
        uint256 eggId = breeding[EGG_ID];
        uint256 firstParentId = us.unicornParents[eggId][0];
        uint256 secondParentId = us.unicornParents[eggId][1];

        require(
            breeding.length > 0,
            "Breeding: Cannot retry a transaction that didn't happen"
        );
        require(
            LibEnvironment.getBlockNumber() > breeding[TTL_BLOCK],
            "Breeding: Cannot retry while old TTL is ongoing"
        );
        require(
            LibIdempotence._getNewEggWaitingForRNG(eggId) == true &&
                LibIdempotence._getNewEggReceivedRNGWaitingForTokenURI(eggId) ==
                false,
            "Breeding: Egg has to be waiting for RNG to retry"
        );

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            firstParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            secondParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );

        setClassAndNameDNA(LibRNG.getRuntimeRNG(), eggId, breeding);
        setIdempotenceForRandomnessFulfilled(eggId);

        emit NewEggReadyForTokenURI(roundTripId, eggId, msg.sender);
        emit NewEggReadyForTokenURIV2(
            roundTripId,
            eggId,
            LibERC721.erc721Storage().owners[eggId],
            msg.sender
        );
    }

    function setClassAndNameDNA(
        uint256 randomness,
        uint256 tokenId,
        uint256[8] storage breeding
    ) private {
        uint256 sum = breeding[CLASS_PROBABILITY_0] +
            breeding[CLASS_PROBABILITY_1] +
            breeding[CLASS_PROBABILITY_2];
        uint256 classRNG = randomness % sum;
        uint256 selectedClass;
        if (classRNG < breeding[CLASS_PROBABILITY_0]) {
            //class 0 got selected
            selectedClass = breeding[POSSIBLE_CLASS_0];
        } else if (
            classRNG <
            breeding[CLASS_PROBABILITY_0] + breeding[CLASS_PROBABILITY_1]
        ) {
            //class 1 got selected
            selectedClass = breeding[POSSIBLE_CLASS_1];
        } else {
            require(
                breeding[CLASS_PROBABILITY_2] > 0,
                "LibBreeding: Invalid class RNG roll"
            );
            //hidden class got selected
            selectedClass = breeding[POSSIBLE_CLASS_2];
        }

        uint256[2] memory unicornName = LibUnicornNames._getRandomName(
            randomness,
            randomness
        );

        uint256 dna = LibUnicornDNA._getDNA(tokenId);
        dna = LibUnicornDNA._setClass(dna, uint8(selectedClass));
        dna = LibUnicornDNA._setFirstNameIndex(dna, unicornName[0]);
        dna = LibUnicornDNA._setLastNameIndex(dna, unicornName[1]);
        LibUnicornDNA._setDNA(tokenId, dna);
        LibStatCache.cacheNaturalStats(tokenId);
    }

    function setIdempotenceForRandomnessFulfilled(uint256 eggId) private {
        LibIdempotence._setNewEggWaitingForRNG(eggId, false);
        LibIdempotence._setNewEggReceivedRNGWaitingForTokenURI(eggId, true);
        // parents are still breeding, so parentIsBreeding = true.
    }

    function breedingFulfillRandomness(
        uint256 vrfRequestId,
        uint256 randomness
    ) internal {
        uint256 roundTripId = breedingStorage().roundTripIdByVRFRequestId[
            vrfRequestId
        ];
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();

        uint256[8] storage breeding = breedingStorage().breedingByRoundTripId[
            roundTripId
        ];
        uint256 eggId = breeding[EGG_ID];
        uint256 firstParentId = us.unicornParents[eggId][0];
        uint256 secondParentId = us.unicornParents[eggId][1];
        address playerWallet = LibERC721.erc721Storage().owners[firstParentId];

        require(
            LibEnvironment.getBlockNumber() < breeding[TTL_BLOCK],
            "Breeding: TTL must be valid"
        );
        require(
            LibIdempotence._getParentIsBreeding(firstParentId),
            "LibBreeding: First parent has to be breeding"
        );
        require(
            LibIdempotence._getParentIsBreeding(secondParentId),
            "LibBreeding: Second parent has to be breeding"
        );
        require(
            LibIdempotence._getNewEggWaitingForRNG(eggId) == true &&
                LibIdempotence._getNewEggReceivedRNGWaitingForTokenURI(eggId) ==
                false,
            "Breeding: Egg has to be waiting for RNG to fulfillRandomness"
        );

        setClassAndNameDNA(randomness, eggId, breeding);
        setIdempotenceForRandomnessFulfilled(eggId);

        emit NewEggReadyForTokenURI(roundTripId, eggId, playerWallet);
        emit NewEggReadyForTokenURIV2(
            roundTripId,
            eggId,
            playerWallet,
            msg.sender
        );
    }

    function setIdempotenceForBreedingComplete(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 eggId
    ) private {
        LibIdempotence._setParentIsBreeding(secondParentId, false);
        LibIdempotence._setParentIsBreeding(firstParentId, false);
        // setting all flags in false for the new egg to start clean
        LibIdempotence._clearState(eggId);
    }

    function finishBreeding(
        uint256 roundTripId,
        uint256 eggId,
        uint256 firstParentId,
        uint256 secondParentId,
        string calldata tokenURI
    ) internal {
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            firstParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            secondParentId,
            IPermissionProvider.Permission.UNICORN_BREEDING_ALLOWED
        );
        require(
            LibIdempotence._getParentIsBreeding(firstParentId),
            "LibBreeding: Parent 1 has to be breeding."
        );
        require(
            LibIdempotence._getParentIsBreeding(secondParentId),
            "LibBreeding: Parent 2 has to be breeding."
        );
        require(
            LibIdempotence._getNewEggWaitingForRNG(eggId) == false &&
                LibIdempotence._getNewEggReceivedRNGWaitingForTokenURI(eggId) ==
                true,
            "LibBreeding: Randomness has to be fulfilled to finish breeding."
        );

        setIdempotenceForBreedingComplete(firstParentId, secondParentId, eggId);
        LibERC721.setTokenURI(eggId, tokenURI);
        address nftOwner = LibERC721.ownerOf(firstParentId);
        LibERC721.safeTransfer(address(this), nftOwner, eggId, "");
        uint256 dna = LibUnicornDNA._getDNA(eggId);
        dna = LibUnicornDNA._setGameLocked(dna, true);
        LibUnicornDNA._setDNA(eggId, dna);
        LibStatCache.updateLock(eggId, true);

        delete breedingStorage().breedingByRoundTripId[roundTripId];
        emit BreedingComplete(roundTripId, eggId);
        emit BreedingCompleteV2(roundTripId, eggId, nftOwner);
        emit UnicornEggCreated(
            firstParentId,
            secondParentId,
            eggId,
            msg.sender
        );
        emit UnicornEggCreatedV2(
            firstParentId,
            secondParentId,
            eggId,
            nftOwner,
            msg.sender
        );
    }

    function getEggAndParentsIdByRoundTripId(
        uint256 roundTripId
    ) internal view returns (uint256, uint256, uint256) {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        uint256[8] storage breeding = breedingStorage().breedingByRoundTripId[
            roundTripId
        ];
        uint256 eggId = breeding[EGG_ID];
        return (
            eggId,
            us.unicornParents[eggId][0],
            us.unicornParents[eggId][1]
        );
    }

    function beginBreedingGenerateMessageHash(
        uint256 roundTripId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 bundleId,
        uint256 blockDeadline
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "BeginBreedingPayload(uint256 roundTripId, uint256 firstParentId, uint256 secondParentId, uint256[3] memory possibleClasses, uint256[3] memory classProbabilities, uint256 owedRBW, uint256 owedUNIM, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                firstParentId,
                secondParentId,
                possibleClasses,
                classProbabilities,
                owedRBW,
                owedUNIM,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }
}
