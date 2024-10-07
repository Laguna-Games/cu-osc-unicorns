// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibIdempotence} from "../libraries/LibIdempotence.sol";
import {LibRNG} from "../../lib/cu-osc-common/src/libraries/LibRNG.sol";
import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibPermissions} from "./LibPermissions.sol";
import {LibStatCache} from "./LibStatCache.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";

/// @custom:storage-location erc7201:games.laguna.LibHatching
library LibHatching {
    event HatchingRNGRequested(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed playerWallet
    );
    event HatchingRNGRequestedV2(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed owner,
        address playerWallet
    );
    event HatchingReadyForTokenURI(
        uint256 indexed roundTripId,
        address indexed playerWallet
    );
    event HatchingReadyForTokenURIV2(
        uint256 indexed roundTripId,
        address indexed owner,
        address indexed playerWallet
    );
    event HatchingComplete(
        uint256 indexed roundTripId,
        address indexed playerWallet
    );
    event HatchingCompleteV2(
        uint256 indexed roundTripId,
        address indexed owner,
        address indexed playerWallet
    );

    //  @dev Storage slot for Hatching Storage
    bytes32 internal constant HATCHING_STORAGE_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.LibHatching")) - 1)
        ) & ~bytes32(uint256(0xff));

    string private constant CALLBACK_SIGNATURE =
        "fulfillHatchingRandomness(uint256,uint256[])";

    uint256 private constant BODY_SLOT = 1;
    uint256 private constant FACE_SLOT = 2;
    uint256 private constant HORN_SLOT = 3;
    uint256 private constant HOOVES_SLOT = 4;
    uint256 private constant MANE_SLOT = 5;
    uint256 private constant TAIL_SLOT = 6;

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

    uint256 private constant SALT_41 = 41;
    uint256 private constant SALT_42 = 42;
    uint256 private constant SALT_43 = 43;
    uint256 private constant SALT_44 = 44;
    uint256 private constant SALT_45 = 45;
    uint256 private constant SALT_46 = 46;

    uint256 private constant SALT_51 = 51;
    uint256 private constant SALT_52 = 52;
    uint256 private constant SALT_53 = 53;
    uint256 private constant SALT_54 = 54;
    uint256 private constant SALT_55 = 55;
    uint256 private constant SALT_56 = 56;

    uint256 private constant SALT_61 = 61;
    uint256 private constant SALT_62 = 62;
    uint256 private constant SALT_63 = 63;
    uint256 private constant SALT_64 = 64;
    uint256 private constant SALT_65 = 65;
    uint256 private constant SALT_66 = 66;

    struct LibHatchingStorage {
        mapping(uint256 vrfRequestId => uint256 blockDeadline) blockDeadlineByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 roundTripId) roundTripIdByVRFRequestId;
        mapping(uint256 roundTripId => uint256 vrfRequestId) vrfRequestIdByRoundTripId;
        mapping(uint256 vrfRequestId => uint256 tokenId) tokenIdByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 inheritanceChance) inheritanceChanceByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 randomness) rngByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 rngBlockNumber) rngBlockNumberByVRFRequestId;
        mapping(uint256 vrfRequestId => uint256 birthday) birthdayByVRFRequestId;
        mapping(uint256 tokenId => uint256 roundTripId) roundTripIdByTokenId;
    }

    function hatchingStorage()
        internal
        pure
        returns (LibHatchingStorage storage lhs)
    {
        bytes32 position = HATCHING_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lhs.slot := position
        }
    }

    function saveDataOnHatchingStruct(
        uint256 roundTripId,
        uint256 vrfRequestId,
        uint256 blockDeadline,
        uint256 tokenId,
        uint256 inheritanceChance
    ) internal {
        LibHatchingStorage storage lhs = hatchingStorage();
        lhs.blockDeadlineByVRFRequestId[vrfRequestId] = blockDeadline;
        lhs.roundTripIdByVRFRequestId[vrfRequestId] = roundTripId;
        lhs.tokenIdByVRFRequestId[vrfRequestId] = tokenId;
        lhs.inheritanceChanceByVRFRequestId[vrfRequestId] = inheritanceChance;
        lhs.vrfRequestIdByRoundTripId[roundTripId] = vrfRequestId;
        lhs.roundTripIdByTokenId[tokenId] = roundTripId;
        lhs.birthdayByVRFRequestId[vrfRequestId] = block.timestamp;
    }

    function cleanUpRoundTrip(uint256 vrfRequestId) private {
        LibHatchingStorage storage lhs = hatchingStorage();
        uint256 roundTripId = lhs.roundTripIdByVRFRequestId[vrfRequestId];
        uint256 tokenId = lhs.tokenIdByVRFRequestId[vrfRequestId];
        delete lhs.blockDeadlineByVRFRequestId[vrfRequestId];
        delete lhs.roundTripIdByVRFRequestId[vrfRequestId];
        delete lhs.vrfRequestIdByRoundTripId[roundTripId];
        delete lhs.tokenIdByVRFRequestId[vrfRequestId];
        delete lhs.inheritanceChanceByVRFRequestId[vrfRequestId];
        delete lhs.rngByVRFRequestId[vrfRequestId];
        delete lhs.rngBlockNumberByVRFRequestId[vrfRequestId];
        delete lhs.birthdayByVRFRequestId[vrfRequestId];
        delete lhs.roundTripIdByTokenId[tokenId];
    }

    function getVRFRequestId(
        uint256 roundTripId
    ) internal view returns (uint256) {
        return hatchingStorage().vrfRequestIdByRoundTripId[roundTripId];
    }

    function getRoundTripId(
        uint256 vrfRequestId
    ) private view returns (uint256) {
        return hatchingStorage().roundTripIdByVRFRequestId[vrfRequestId];
    }

    function getRoundTripIdForToken(
        uint256 tokenId
    ) private view returns (uint256) {
        return hatchingStorage().roundTripIdByTokenId[tokenId];
    }

    function getBlockDeadline(
        uint256 vrfRequestId
    ) private view returns (uint256) {
        return hatchingStorage().blockDeadlineByVRFRequestId[vrfRequestId];
    }

    function getTokenId(uint256 vrfRequestId) internal view returns (uint256) {
        return hatchingStorage().tokenIdByVRFRequestId[vrfRequestId];
    }

    function setRandomness(uint256 vrfRequestId, uint256 randomness) internal {
        LibHatchingStorage storage lhs = hatchingStorage();
        lhs.rngByVRFRequestId[vrfRequestId] = randomness;
        lhs.rngBlockNumberByVRFRequestId[vrfRequestId] = LibEnvironment
            .getBlockNumber();
    }

    function setBirthday(uint256 vrfRequestId, uint256 timestamp) internal {
        hatchingStorage().birthdayByVRFRequestId[vrfRequestId] = timestamp;
    }

    function shouldUsePredictiveDNA(
        uint256 tokenId
    ) internal view returns (bool) {
        if (
            LibIdempotence._getHatchingRandomnessFulfilled(tokenId) &&
            !LibIdempotence._getHatchingStarted(tokenId)
        ) {
            LibHatchingStorage storage lhs = hatchingStorage();
            uint256 roundTripId = lhs.roundTripIdByTokenId[tokenId];
            uint256 vrfRequestId = lhs.vrfRequestIdByRoundTripId[roundTripId];
            if (
                lhs.rngBlockNumberByVRFRequestId[vrfRequestId] > 0 &&
                lhs.rngBlockNumberByVRFRequestId[vrfRequestId] <
                LibEnvironment.getBlockNumber()
            ) {
                return true;
            }
        }
        return false;
    }

    function predictBabyBirthday(
        uint256 tokenId
    ) internal view returns (uint256) {
        require(
            !LibIdempotence._getHatchingStarted(tokenId),
            "LibHatching: RNG not ready"
        );
        require(
            LibIdempotence._getHatchingRandomnessFulfilled(tokenId),
            "LibHatching: Waiting for VRF TTL"
        );
        LibHatchingStorage storage lhs = hatchingStorage();
        uint256 roundTripId = lhs.roundTripIdByTokenId[tokenId];
        uint256 vrfRequestId = lhs.vrfRequestIdByRoundTripId[roundTripId];
        uint256 eggDNA = LibUnicornDNA._getCanonicalDNA(tokenId);
        require(
            LibUnicornDNA._getLifecycleStage(eggDNA) ==
                LibUnicornDNA.LIFECYCLE_EGG,
            "LibHatching: DNA has already been persisted (birthday)"
        );
        return lhs.birthdayByVRFRequestId[vrfRequestId];
    }

    struct OnDemandDNA {
        uint8 matching; //{0: neither,  1: firstParent,  2: secondParent,  3: both}
        uint8 classId;
        uint256 inheritanceChance;
        uint256 randomness;
        uint256 firstParentDNA;
        uint256 secondParentDNA;
    }

    //  This is gigantic hack to move gas costs out of the Chainlink VRF call. Instead of rolling for
    //  random DNA and saving it, the dna is calculated on-the-fly when it's needed. When hatching is
    //  completed, this dna is written into storage and the temporary state is deleted. -RS
    //
    //  This code MUST be deterministic - DO NOT MODIFY THE RANDOMNESS OR SALT CONSTANTS

    function predictBabyDNA(uint256 tokenId) internal view returns (uint256) {
        require(
            !LibIdempotence._getHatchingStarted(tokenId),
            "LibHatching: RNG not ready"
        );
        require(
            LibIdempotence._getHatchingRandomnessFulfilled(tokenId),
            "LibHatching: Waiting for VRF TTL"
        );
        LibHatchingStorage storage lhs = hatchingStorage();

        uint256 vrfRequestId = lhs.vrfRequestIdByRoundTripId[
            lhs.roundTripIdByTokenId[tokenId]
        ];
        require(
            lhs.rngBlockNumberByVRFRequestId[vrfRequestId] > 0,
            "LibHatching: No RNG set"
        );
        require(
            lhs.rngBlockNumberByVRFRequestId[vrfRequestId] <
                LibEnvironment.getBlockNumber(),
            "LibHatching: Prediction masked during RNG set block"
        );

        uint256 dna = LibUnicornDNA._getCanonicalDNA(tokenId);

        require(
            LibUnicornDNA._getLifecycleStage(dna) ==
                LibUnicornDNA.LIFECYCLE_EGG,
            "LibHatching: DNA has already been persisted (dna)"
        );

        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        OnDemandDNA memory data = OnDemandDNA({
            matching: 0,
            classId: LibUnicornDNA._getClass(dna),
            inheritanceChance: lhs.inheritanceChanceByVRFRequestId[
                vrfRequestId
            ],
            randomness: lhs.rngByVRFRequestId[vrfRequestId],
            firstParentDNA: LibUnicornDNA._getDNA(
                us.unicornParents[tokenId][0]
            ),
            secondParentDNA: LibUnicornDNA._getDNA(
                us.unicornParents[tokenId][1]
            )
        });

        if (data.classId == LibUnicornDNA._getClass(data.firstParentDNA)) {
            data.matching += 1;
        }

        if (data.classId == LibUnicornDNA._getClass(data.secondParentDNA)) {
            data.matching += 2;
        }

        dna = LibUnicornDNA._setLifecycleStage(
            dna,
            LibUnicornDNA.LIFECYCLE_BABY
        );

        uint256 partId;

        //  BODY
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_11) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_12) == 1) {
                    dna = LibUnicornDNA._inheritBody(dna, data.firstParentDNA);
                } else {
                    dna = LibUnicornDNA._inheritBody(dna, data.secondParentDNA);
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritBody(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritBody(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                BODY_SLOT,
                data.randomness,
                SALT_13
            );
            dna = LibUnicornDNA._multiSetBody(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_15),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_16)
            );
        }

        //  FACE
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_21) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_22) == 1) {
                    dna = LibUnicornDNA._inheritFace(dna, data.firstParentDNA);
                } else {
                    dna = LibUnicornDNA._inheritFace(dna, data.secondParentDNA);
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritFace(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritFace(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                FACE_SLOT,
                data.randomness,
                SALT_23
            );
            dna = LibUnicornDNA._multiSetFace(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_25),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_26)
            );
        }

        //  HORN
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_31) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_32) == 1) {
                    dna = LibUnicornDNA._inheritHorn(dna, data.firstParentDNA);
                } else {
                    dna = LibUnicornDNA._inheritHorn(dna, data.secondParentDNA);
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritHorn(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritHorn(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                HORN_SLOT,
                data.randomness,
                SALT_33
            );
            dna = LibUnicornDNA._multiSetHorn(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_35),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_36)
            );
        }

        //  HOOVES
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_41) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_42) == 1) {
                    dna = LibUnicornDNA._inheritHooves(
                        dna,
                        data.firstParentDNA
                    );
                } else {
                    dna = LibUnicornDNA._inheritHooves(
                        dna,
                        data.secondParentDNA
                    );
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritHooves(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritHooves(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                HOOVES_SLOT,
                data.randomness,
                SALT_43
            );
            dna = LibUnicornDNA._multiSetHooves(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_45),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_46)
            );
        }

        //  MANE
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_51) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_52) == 1) {
                    dna = LibUnicornDNA._inheritMane(dna, data.firstParentDNA);
                } else {
                    dna = LibUnicornDNA._inheritMane(dna, data.secondParentDNA);
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritMane(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritMane(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                MANE_SLOT,
                data.randomness,
                SALT_53
            );
            dna = LibUnicornDNA._multiSetMane(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_55),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_56)
            );
        }

        //  TAIL
        if (
            data.matching > 0 &&
            LibRNG.expand(10000, data.randomness, SALT_61) <
            data.inheritanceChance
        ) {
            //  inherit
            if (data.matching == 3) {
                if (LibRNG.expand(2, data.randomness, SALT_62) == 1) {
                    dna = LibUnicornDNA._inheritTail(dna, data.firstParentDNA);
                } else {
                    dna = LibUnicornDNA._inheritTail(dna, data.secondParentDNA);
                }
            } else if (data.matching == 2) {
                dna = LibUnicornDNA._inheritTail(dna, data.secondParentDNA);
            } else {
                dna = LibUnicornDNA._inheritTail(dna, data.firstParentDNA);
            }
        } else {
            //  randomize
            partId = getRandomPartId(
                gs,
                data.classId,
                TAIL_SLOT,
                data.randomness,
                SALT_63
            );
            dna = LibUnicornDNA._multiSetTail(
                dna,
                gs.bodyPartLocalIdFromGlobalId[partId],
                gs.bodyPartInheritedGene[partId],
                getRandomGeneId(gs, data.classId, data.randomness, SALT_65),
                getRandomGeneId(gs, data.classId, data.randomness, SALT_66)
            );
        }
        return dna;
    }

    //  Chooses a bodypart from the weighted random pool in `partsBySlot` and returns the id
    //  @param _classId Index the unicorn class
    //  @param _slotId Index of the bodypart slot
    //  @return Struct of the body part
    function getRandomPartId(
        LibGenes.GeneStorage storage gs,
        uint256 _classId,
        uint256 _slotId,
        uint256 _rngSeed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 numBodyParts = gs.bodyPartBuckets[_classId][_slotId].length;
        uint256 totalWeight = 0;
        for (uint i = 0; i < numBodyParts; i++) {
            totalWeight += gs.bodyPartWeight[
                gs.bodyPartBuckets[_classId][_slotId][i]
            ];
        }
        uint256 target = LibRNG.expand(totalWeight, _rngSeed, _salt) + 1;
        uint256 cumulativeWeight = 0;
        for (uint i = 0; i < numBodyParts; ++i) {
            uint256 globalId = gs.bodyPartBuckets[_classId][_slotId][i];
            uint256 partWeight = gs.bodyPartWeight[globalId];
            cumulativeWeight += partWeight;
            if (target <= cumulativeWeight) {
                return globalId;
            }
        }
        revert("LibHatching: Failed getting RNG bodyparts");
    }

    function getRandomGeneId(
        LibGenes.GeneStorage storage gs,
        uint256 _classId,
        uint256 _rngSeed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 numGenes = gs.geneBuckets[_classId].length;
        uint256 target = LibRNG.expand(
            gs.geneBucketSumWeights[_classId],
            _rngSeed,
            _salt
        ) + 1;
        uint256 cumulativeWeight = 0;
        for (uint i = 0; i < numGenes; ++i) {
            uint256 geneId = gs.geneBuckets[_classId][i];
            cumulativeWeight += gs.geneWeightById[geneId];
            if (target <= cumulativeWeight) {
                return geneId;
            }
        }
        revert("LibHatching: Failed getting RNG gene");
    }

    function completeBeginHatching(
        uint256 vrfRequestId,
        uint256 blockDeadline,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 roundTripId
    ) private {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();

        saveDataOnHatchingStruct(
            roundTripId,
            vrfRequestId,
            blockDeadline,
            tokenId,
            inheritanceChance
        );
        LibIdempotence._setHatchingStarted(tokenId, true);
        emit HatchingRNGRequested(
            roundTripId,
            bytes32(vrfRequestId),
            erc721.owners[tokenId]
        );
        emit HatchingRNGRequestedV2(
            roundTripId,
            bytes32(vrfRequestId),
            erc721.owners[tokenId],
            msg.sender
        );
    }

    function beginHatching(
        uint256 roundTripId,
        uint256 blockDeadline,
        uint256 tokenId,
        uint256 inheritanceChance
    ) internal {
        validateBeginHatching(blockDeadline, tokenId);
        uint256 vrfRequestId = LibRNG.requestRandomness(CALLBACK_SIGNATURE);
        completeBeginHatching(
            vrfRequestId,
            blockDeadline,
            tokenId,
            inheritanceChance,
            roundTripId
        );
    }

    function validateBeginHatching(
        uint256 blockDeadline,
        uint256 tokenId
    ) private view {
        require(
            blockDeadline >=
                LibRNG.rngStorage().blocksToRespond +
                    LibEnvironment.getBlockNumber(),
            "LibHatching: TTL has expired."
        );

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_HATCHING_ALLOWED
        );
        require(
            !LibIdempotence._getGenesisHatching(tokenId),
            "LibHatching: IDMP currently genesisHatching"
        );
        require(
            !LibIdempotence._getHatching(tokenId),
            "LibHatching: IDMP currently hatching"
        );
        require(
            !LibIdempotence._getHatchingStarted(tokenId),
            "LibHatching: IDMP already started hatching"
        );
        require(
            !LibIdempotence._getHatchingRandomnessFulfilled(tokenId),
            "LibHatching: IDMP already received hatch RNG"
        );
        require(
            !LibIdempotence._getNewEggWaitingForRNG(tokenId),
            "LibHatching: IDMP new egg waiting for RNG"
        );
        require(
            !LibIdempotence._getNewEggReceivedRNGWaitingForTokenURI(tokenId),
            "LibHatching: IDMP new egg waiting for tokenURI"
        );
        require(
            LibUnicorn.unicornStorage().bioClock[tokenId] + 300 <=
                block.timestamp,
            "LibHatching: Egg has to be at least 5 minutes old to hatch"
        );
        uint256 dna = LibUnicornDNA._getDNA(tokenId);
        LibUnicornDNA.enforceDNAVersionMatch(dna);
        require(
            LibUnicornDNA._getLifecycleStage(dna) ==
                LibUnicornDNA.LIFECYCLE_EGG,
            "LibHatching: Only eggs can be hatched"
        );
        require(
            !LibUnicornDNA._getOrigin(dna),
            "LibHatching: Only non origin eggs can be hatched in this facet"
        );
        require(
            LibUnicornDNA._getGameLocked(dna),
            "LibHatching: Egg must be locked in order to begin hatching"
        );
    }

    function hatchingFulfillRandomness(
        uint256 requestId,
        uint256 randomness
    ) internal {
        LibCheck.enforceBlockDeadlineIsValid(getBlockDeadline(requestId));
        uint256 tokenId = getTokenId(requestId);
        require(
            LibIdempotence._getHatchingStarted(tokenId),
            "LibHatching: Hatching has to be in STARTED state to fulfillRandomness"
        );
        setRandomness(requestId, randomness);
        updateIdempotenceAndEmitEvent(tokenId, getRoundTripId(requestId));
    }

    function updateIdempotenceAndEmitEvent(
        uint256 tokenId,
        uint256 roundTripId
    ) internal {
        LibIdempotence._setHatchingStarted(tokenId, false);
        LibIdempotence._setHatchingRandomnessFulfilled(tokenId, true);
        emit HatchingReadyForTokenURI(
            roundTripId,
            LibERC721.erc721Storage().owners[tokenId]
        );
        emit HatchingReadyForTokenURIV2(
            roundTripId,
            LibERC721.erc721Storage().owners[tokenId],
            msg.sender
        );
    }

    //  Chooses a bodypart from the weighted random pool in `partsBySlot` and returns the id
    //  @param _classId Index the unicorn class
    //  @param _slotId Index of the bodypart slot
    //  @return Struct of the body part
    function getRandomPartId(
        uint256 _classId,
        uint256 _slotId
    ) internal returns (uint256) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        uint256 i = 0;
        uint256 numBodyParts = gs.bodyPartBuckets[_classId][_slotId].length;

        uint256 totalWeight = 0;
        for (i = 0; i < numBodyParts; i++) {
            totalWeight += gs.bodyPartWeight[
                gs.bodyPartBuckets[_classId][_slotId][i]
            ];
        }

        uint256 target = LibRNG.getRuntimeRNG(totalWeight) + 1;
        uint256 cumulativeWeight = 0;

        for (i = 0; i < numBodyParts; i++) {
            uint256 globalId = gs.bodyPartBuckets[_classId][_slotId][i];
            uint256 partWeight = gs.bodyPartWeight[globalId];
            cumulativeWeight += partWeight;
            if (target <= cumulativeWeight) {
                return globalId;
            }
        }
        revert("LibHatching: Failed getting RNG bodyparts");
    }

    function getRandomGeneId(uint256 _classId) internal returns (uint256) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        uint256 numGenes = gs.geneBuckets[_classId].length;

        uint256 i = 0;
        uint256 totalWeight = gs.geneBucketSumWeights[_classId];

        uint256 target = LibRNG.getRuntimeRNG(totalWeight) + 1;
        uint256 cumulativeWeight = 0;

        for (i = 0; i < numGenes; i++) {
            uint256 geneId = gs.geneBuckets[_classId][i];
            cumulativeWeight += gs.geneWeightById[geneId];
            if (target <= cumulativeWeight) {
                return geneId;
            }
        }

        revert("LibHatching: Failed getting RNG gene");
    }

    function getParentDNAs(
        uint256 tokenId
    ) internal view returns (uint256[2] memory parentDNA) {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        uint256 firstParentId = us.unicornParents[tokenId][0];
        uint256 secondParentId = us.unicornParents[tokenId][1];
        parentDNA[0] = LibUnicornDNA._getDNA(firstParentId);
        parentDNA[1] = LibUnicornDNA._getDNA(secondParentId);
        return parentDNA;
    }

    function retryHatching(uint256 roundTripId) internal {
        uint256 requestId = getVRFRequestId(roundTripId);
        uint256 tokenId = getTokenId(requestId);

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_HATCHING_ALLOWED
        );
        uint256 blockDeadline = getBlockDeadline(requestId);
        require(blockDeadline > 0, "LibHatching: Transaction not found");
        require(
            LibEnvironment.getBlockNumber() > blockDeadline,
            "LibHatching: Cannot retry while old TTL is ongoing"
        );
        require(
            LibIdempotence._getHatchingStarted(tokenId),
            "LibHatching: Hatching has to be in STARTED state to retry hatching"
        );
        uint256 randomness = LibRNG.getRuntimeRNG();
        setRandomness(requestId, randomness);
        updateIdempotenceAndEmitEvent(tokenId, roundTripId);
    }

    function finishHatching(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 vrfRequestId,
        string calldata tokenURI
    ) internal {
        LibERC721.ERC721Storage storage erc721 = LibERC721.erc721Storage();
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();

        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_HATCHING_ALLOWED
        );
        require(
            LibIdempotence._getHatchingRandomnessFulfilled(tokenId),
            "LibHatching: Cannot finish hatching before randomness has been fulfilled"
        );
        LibERC721.setTokenURI(tokenId, tokenURI);

        uint256 newDNA;
        uint256 newBirthday = predictBabyBirthday(tokenId);

        if (LibUnicornDNA.dnaStorage().cachedDNA[tokenId] > 0) {
            // Check for any DNA held over from old versions of the deterministic logic...
            newDNA = LibUnicornDNA.dnaStorage().cachedDNA[tokenId];
            delete LibUnicornDNA.dnaStorage().cachedDNA[tokenId];
        } else {
            newDNA = predictBabyDNA(tokenId);
        }

        us.hatchBirthday[tokenId] = newBirthday;
        LibUnicornDNA._setDNA(tokenId, newDNA);
        us.bioClock[tokenId] = block.timestamp;

        LibIdempotence._setHatchingRandomnessFulfilled(tokenId, false);
        emit HatchingComplete(roundTripId, erc721.owners[tokenId]);
        emit HatchingCompleteV2(
            roundTripId,
            erc721.owners[tokenId],
            msg.sender
        );
        //  clean up workflow data:
        cleanUpRoundTrip(vrfRequestId);
        LibStatCache.cacheNaturalStats(tokenId);
    }
}
