// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibIdempotence} from "../libraries/LibIdempotence.sol";
import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibRNG} from "../../lib/cu-osc-common/src/libraries/LibRNG.sol";
import {LibStatCache} from "../libraries/LibStatCache.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibCheck} from "../libraries/LibCheck.sol";

//  Genesis unicorns
contract HatchFacet {
    event HatchStartedEvent(
        uint256 indexed tokenId,
        uint256 eggDNA,
        uint256 hatchDNA,
        address indexed hatcher
    );

    event HatchFinishedEvent(
        uint256 indexed tokenId,
        uint256 hatchDNA,
        address indexed hatcher
    );

    function batchFinishHatchingEgg(
        uint256[] calldata _tokenIds,
        string[] calldata _tokenURIs
    ) external {
        LibCheck.enforceIsOwnerOrGameServer();
        for (uint256 i = 0; i < _tokenURIs.length; ++i) {
            _finishHatchingEgg(_tokenIds[i], _tokenURIs[i]);
        }
    }

    function finishHatchingEgg(
        uint256 _tokenId,
        string calldata _tokenURI
    ) external {
        LibCheck.enforceIsOwnerOrGameServer();
        _finishHatchingEgg(_tokenId, _tokenURI);
    }

    function _finishHatchingEgg(
        uint256 _tokenId,
        string calldata _tokenURI
    ) internal {
        require(LibERC721.exists(_tokenId), "HatchFacet: Non-existent token");
        LibERC721.setTokenURI(_tokenId, _tokenURI);

        if (
            LibIdempotence._getGenesisHatching(_tokenId) ||
            LibIdempotence._getHatching(_tokenId)
        ) {
            LibIdempotence._clearState(_tokenId);
        }

        emit HatchFinishedEvent(
            _tokenId,
            LibUnicornDNA._getDNA(_tokenId),
            msg.sender
        );
    }

    function beginHatchingEgg(uint256 _tokenId) external {
        LibERC721.enforceCallerOwnsNFT(_tokenId);
        uint256 dna = LibUnicornDNA._getDNA(_tokenId);
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        require(dna > 0, "HatchFacet: No DNA");

        require(
            LibUnicornDNA._getVersion(dna) == LibUnicornDNA._targetDNAVersion(),
            "HatchFacet: Bad DNA version"
        );

        require(
            LibUnicornDNA._getLifecycleStage(dna) ==
                LibUnicornDNA.LIFECYCLE_EGG,
            "HatchFacet: Not an egg"
        );

        require(
            LibIdempotence._getGenesisHatching(_tokenId) == false,
            "HatchFacet: Already hatching"
        );

        bool origin = LibUnicornDNA._getOrigin(dna);
        if (origin) {
            // Set the Unicorn to "genesis-hatching" state
            LibIdempotence._setGenesisHatching(_tokenId, true);
            //  RNG - commit/reveal model
            LibRNG.rngStorage().rngNonce = uint(
                keccak256(
                    abi.encodePacked(
                        LibERC721.erc721Storage().tokenURIs[_tokenId],
                        _tokenId
                    )
                )
            );
        } else {
            //  Code path moved to HatchingFacet
            revert("beginHatchingEgg:bad code path"); //  Not implemented - RS
        }

        uint256 eggDNA = dna;
        dna = LibUnicornDNA._setLifecycleStage(
            dna,
            LibUnicornDNA.LIFECYCLE_BABY
        );

        uint256 classId = LibUnicornDNA._getClass(dna);

        uint256[] memory parts = new uint256[](7);
        uint256[] memory majorGenes = new uint256[](7);
        uint256[] memory midGenes = new uint256[](7);
        uint256[] memory minorGenes = new uint256[](7);

        for (uint256 i = 1; i <= 6; ++i) {
            parts[i] = getRandomPartId(classId, i);
            majorGenes[i] = gs.bodyPartInheritedGene[parts[i]];
            midGenes[i] = getRandomGeneId(classId);
            minorGenes[i] = getRandomGeneId(classId);
        }

        if (LibUnicornDNA._getOrigin(dna)) {
            //  Special case: Genesis Egg
            dna = LibUnicornDNA._setLifecycleStage(
                dna,
                LibUnicornDNA.LIFECYCLE_ADULT
            );
            dna = LibUnicornDNA._setBreedingPoints(
                dna,
                LibUnicornDNA.DEFAULT_BREEDING_POINTS
            );

            for (uint256 i = 1; i <= 6; ++i) {
                majorGenes[i] = attemptGeneUpgrade(majorGenes[i], 1);
                midGenes[i] = attemptGeneUpgrade(midGenes[i], 2);
                minorGenes[i] = attemptGeneUpgrade(minorGenes[i], 3);
            }
        }

        dna = LibUnicornDNA._setBodyPart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[1]]
        );
        dna = LibUnicornDNA._setFacePart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[2]]
        );
        dna = LibUnicornDNA._setHornPart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[3]]
        );
        dna = LibUnicornDNA._setHoovesPart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[4]]
        );
        dna = LibUnicornDNA._setManePart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[5]]
        );
        dna = LibUnicornDNA._setTailPart(
            dna,
            gs.bodyPartLocalIdFromGlobalId[parts[6]]
        );

        dna = LibUnicornDNA._setBodyMajorGene(dna, majorGenes[1]);
        dna = LibUnicornDNA._setFaceMajorGene(dna, majorGenes[2]);
        dna = LibUnicornDNA._setHornMajorGene(dna, majorGenes[3]);
        dna = LibUnicornDNA._setHoovesMajorGene(dna, majorGenes[4]);
        dna = LibUnicornDNA._setManeMajorGene(dna, majorGenes[5]);
        dna = LibUnicornDNA._setTailMajorGene(dna, majorGenes[6]);

        dna = LibUnicornDNA._setBodyMidGene(dna, midGenes[1]);
        dna = LibUnicornDNA._setFaceMidGene(dna, midGenes[2]);
        dna = LibUnicornDNA._setHornMidGene(dna, midGenes[3]);
        dna = LibUnicornDNA._setHoovesMidGene(dna, midGenes[4]);
        dna = LibUnicornDNA._setManeMidGene(dna, midGenes[5]);
        dna = LibUnicornDNA._setTailMidGene(dna, midGenes[6]);

        dna = LibUnicornDNA._setBodyMinorGene(dna, minorGenes[1]);
        dna = LibUnicornDNA._setFaceMinorGene(dna, minorGenes[2]);
        dna = LibUnicornDNA._setHornMinorGene(dna, minorGenes[3]);
        dna = LibUnicornDNA._setHoovesMinorGene(dna, minorGenes[4]);
        dna = LibUnicornDNA._setManeMinorGene(dna, minorGenes[5]);
        dna = LibUnicornDNA._setTailMinorGene(dna, minorGenes[6]);

        us.hatchBirthday[_tokenId] = block.timestamp;
        us.bioClock[_tokenId] = block.timestamp;

        LibUnicornDNA._setDNA(_tokenId, dna);
        LibStatCache.cacheNaturalStats(_tokenId);
        emit HatchStartedEvent(_tokenId, eggDNA, dna, msg.sender);
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

        uint256 target = LibRNG.getCheapRNG(totalWeight) + 1;
        uint256 cumulativeWeight = 0;

        for (i = 0; i < numBodyParts; i++) {
            uint256 globalId = gs.bodyPartBuckets[_classId][_slotId][i];
            uint256 partWeight = gs.bodyPartWeight[globalId];
            cumulativeWeight += partWeight;
            if (target <= cumulativeWeight) {
                return globalId;
            }
        }
        revert("HatchFacet: Failed getting RNG bodyparts");
    }

    function attemptGeneUpgrade(
        uint256 _geneId,
        uint256 _geneDominance
    ) internal returns (uint256) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        if (gs.geneTierById[_geneId] >= 6) return _geneId;
        uint256 rand = LibRNG.getCheapRNG(100);
        if (
            rand <=
            gs.geneUpgradeChances[gs.geneTierById[_geneId]][_geneDominance]
        ) {
            return gs.geneTierUpgradeById[_geneId];
        }
        return _geneId;
    }

    function getRandomGeneId(uint256 _classId) internal returns (uint256) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        uint256 numGenes = gs.geneBuckets[_classId].length;
        uint256 i = 0;
        uint256 totalWeight = gs.geneBucketSumWeights[_classId];
        uint256 target = LibRNG.getCheapRNG(totalWeight) + 1;
        uint256 cumulativeWeight = 0;

        for (i = 0; i < numGenes; i++) {
            uint256 geneId = gs.geneBuckets[_classId][i];
            cumulativeWeight += gs.geneWeightById[geneId];
            if (target <= cumulativeWeight) {
                return geneId;
            }
        }

        revert("HatchFacet: Failed getting RNG gene");
    }
}
