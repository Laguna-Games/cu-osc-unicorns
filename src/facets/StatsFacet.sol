// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibStats} from "../libraries/LibStats.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibAirlock} from "../libraries/LibAirlock.sol";
import {ITwTUnicornInfo} from "../interfaces/ITwTUnicornInfo.sol";
import {IUnicornStatCache} from "../interfaces/IUnicornStats.sol";
import {LibStatCache} from "../libraries/LibStatCache.sol";
import {LibGenes} from "../libraries/LibGenes.sol";

contract StatsFacet is ITwTUnicornInfo {
    function getAttack(uint256 _dna) external view returns (uint256) {
        return LibStats.getAttack(_dna);
    }

    function getAccuracy(uint256 _dna) external view returns (uint256) {
        return LibStats.getAccuracy(_dna);
    }

    function getMovementSpeed(uint256 _dna) external view returns (uint256) {
        return LibStats.getMovementSpeed(_dna);
    }

    function getAttackSpeed(uint256 _dna) external view returns (uint256) {
        return LibStats.getAttackSpeed(_dna);
    }

    function getDefense(uint256 _dna) external view returns (uint256) {
        return LibStats.getDefense(_dna);
    }

    function getVitality(uint256 _dna) external view returns (uint256) {
        return LibStats.getVitality(_dna);
    }

    function getResistance(uint256 _dna) external view returns (uint256) {
        return LibStats.getResistance(_dna);
    }

    function getMagic(uint256 _dna) external view returns (uint256) {
        return LibStats.getMagic(_dna);
    }

    function getUnicornMetadata(
        uint256 _tokenId
    )
        external
        view
        returns (
            bool origin,
            bool gameLocked,
            bool limitedEdition,
            uint256 lifecycleStage,
            uint256 breedingPoints,
            uint256 unicornClass,
            uint256 hatchBirthday
        )
    {
        uint256 dna = LibUnicornDNA._getDNA(_tokenId);
        LibUnicornDNA.enforceDNAVersionMatch(dna);
        origin = LibUnicornDNA._getOrigin(dna);
        gameLocked = LibUnicornDNA._getGameLocked(dna);
        limitedEdition = LibUnicornDNA._getLimitedEdition(dna);
        lifecycleStage = LibUnicornDNA._getLifecycleStage(dna);
        breedingPoints = LibUnicornDNA._getBreedingPoints(dna);
        unicornClass = LibUnicornDNA._getClass(dna);
        hatchBirthday = LibUnicornDNA._getBirthday(_tokenId);
    }

    function getUnicornBodyParts(
        uint256 _dna
    )
        external
        view
        returns (
            uint256 bodyPartId,
            uint256 facePartId,
            uint256 hornPartId,
            uint256 hoovesPartId,
            uint256 manePartId,
            uint256 tailPartId,
            uint8 mythicCount
        )
    {
        LibUnicornDNA.enforceDNAVersionMatch(_dna);

        if (
            LibUnicornDNA._getLifecycleStage(_dna) ==
            LibUnicornDNA.LIFECYCLE_EGG
        ) {
            return (0, 0, 0, 0, 0, 0, 0);
        }

        uint8 classId = LibUnicornDNA._getClass(_dna);

        (
            bodyPartId,
            facePartId,
            hornPartId,
            hoovesPartId,
            manePartId,
            tailPartId
        ) = getUnicornBodyPartIds(_dna, classId);

        mythicCount = getMythicPartCount(
            bodyPartId,
            facePartId,
            hornPartId,
            hoovesPartId,
            manePartId,
            tailPartId
        );
    }

    function getMythicPartCount(
        uint256 bodyPartId,
        uint256 facePartId,
        uint256 hornPartId,
        uint256 hoovesPartId,
        uint256 manePartId,
        uint256 tailPartId
    ) internal view returns (uint8 mythicCount) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        if (gs.bodyPartIsMythic[bodyPartId]) ++mythicCount;
        if (gs.bodyPartIsMythic[facePartId]) ++mythicCount;
        if (gs.bodyPartIsMythic[hoovesPartId]) ++mythicCount;
        if (gs.bodyPartIsMythic[hornPartId]) ++mythicCount;
        if (gs.bodyPartIsMythic[manePartId]) ++mythicCount;
        if (gs.bodyPartIsMythic[tailPartId]) ++mythicCount;
    }

    function getUnicornBodyPartsLocal(
        uint256 _dna
    )
        external
        view
        returns (
            uint256 bodyPartLocalId,
            uint256 facePartLocalId,
            uint256 hornPartLocalId,
            uint256 hoovesPartLocalId,
            uint256 manePartLocalId,
            uint256 tailPartLocalId
        )
    {
        LibUnicornDNA.enforceDNAVersionMatch(_dna);
        bodyPartLocalId = LibUnicornDNA._getBodyPart(_dna);
        facePartLocalId = LibUnicornDNA._getFacePart(_dna);
        hoovesPartLocalId = LibUnicornDNA._getHoovesPart(_dna);
        hornPartLocalId = LibUnicornDNA._getHornPart(_dna);
        manePartLocalId = LibUnicornDNA._getManePart(_dna);
        tailPartLocalId = LibUnicornDNA._getTailPart(_dna);
    }

    function getStats(
        uint256 _dna
    )
        external
        view
        returns (
            uint256 attack,
            uint256 accuracy,
            uint256 movementSpeed,
            uint256 attackSpeed,
            uint256 defense,
            uint256 vitality,
            uint256 resistance,
            uint256 magic
        )
    {
        return LibStats.getStats(_dna);
    }

    function getPowerScore(uint256 tokenId) public view returns (uint256) {
        return LibStats.getPowerScoreByTokenId(tokenId);
    }

    function getSpeedScore(uint256 tokenId) public view returns (uint256) {
        return LibStats.getSpeedScoreByTokenId(tokenId);
    }

    function getEnduranceScore(uint256 tokenId) public view returns (uint256) {
        return LibStats.getEnduranceScoreByTokenId(tokenId);
    }

    function getIntelligenceScore(
        uint256 tokenId
    ) public view returns (uint256) {
        return LibStats.getIntelligenceScoreByTokenId(tokenId);
    }

    //  TODO - Deprecate this and use StatCacheFacet.getUnicornStatsBatch()
    function twtGetUnicornInfoMultiple(
        uint256[3] memory tokenIds,
        uint256[] memory relevantStats,
        address user
    )
        external
        view
        returns (ITwTUnicornInfo.TwTUnicornInfo[] memory unicornInfo)
    {
        uint256 amountOfUnicorns = 0;
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            if (tokenIds[i] != 0) {
                ++amountOfUnicorns;
            }
            //  TODO: bug here - this will break if the `0` entries are mixed in the array order
        }

        unicornInfo = new ITwTUnicornInfo.TwTUnicornInfo[](amountOfUnicorns);

        for (uint256 i = 0; i < amountOfUnicorns; ++i) {
            uint256 tokenId = tokenIds[i];

            IUnicornStatCache.Stats memory s = LibStatCache
                .getEnhancedStatsFromCacheOrFallthrough(tokenIds[i]);
            uint256[] memory statsValues = new uint256[](relevantStats.length);
            uint8 cursor = 0;
            for (uint8 j = 0; j < relevantStats.length; ++j) {
                if (relevantStats[j] == LibUnicornDNA.STAT_ATTACK) {
                    statsValues[cursor++] = s.attack;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_ACCURACY) {
                    statsValues[cursor++] = s.accuracy;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_MOVE_SPEED) {
                    statsValues[cursor++] = s.moveSpeed;
                } else if (
                    relevantStats[j] == LibUnicornDNA.STAT_ATTACK_SPEED
                ) {
                    statsValues[cursor++] = s.attackSpeed;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_DEFENSE) {
                    statsValues[cursor++] = s.defense;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_VITALITY) {
                    statsValues[cursor++] = s.vitality;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_RESISTANCE) {
                    statsValues[cursor++] = s.resistance;
                } else if (relevantStats[j] == LibUnicornDNA.STAT_MAGIC) {
                    statsValues[cursor++] = s.magic;
                }
            }

            unicornInfo[i] = ITwTUnicornInfo.TwTUnicornInfo({
                belongsToUser: LibERC721.ownerOf(tokenId) == user,
                isTransferrable: LibAirlock.unicornIsTransferable(tokenId),
                isGenesis: s.origin,
                isAdult: s.lifecycleStage == LibUnicornDNA.LIFECYCLE_ADULT,
                amountOfMythicParts: s.mythicCount,
                class: s.class,
                statsValues: statsValues
            });
        }
    }

    function getUnicornBodyPartIds(
        uint256 _dna,
        uint8 class
    )
        internal
        view
        returns (
            uint256 bodyPartId,
            uint256 facePartId,
            uint256 hornPartId,
            uint256 hoovesPartId,
            uint256 manePartId,
            uint256 tailPartId
        )
    {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        bodyPartId = gs.bodyPartGlobalIdFromLocalId[class][1][
            LibUnicornDNA._getBodyPart(_dna)
        ];
        facePartId = gs.bodyPartGlobalIdFromLocalId[class][2][
            LibUnicornDNA._getFacePart(_dna)
        ];
        hornPartId = gs.bodyPartGlobalIdFromLocalId[class][3][
            LibUnicornDNA._getHornPart(_dna)
        ];
        hoovesPartId = gs.bodyPartGlobalIdFromLocalId[class][4][
            LibUnicornDNA._getHoovesPart(_dna)
        ];
        manePartId = gs.bodyPartGlobalIdFromLocalId[class][5][
            LibUnicornDNA._getManePart(_dna)
        ];
        tailPartId = gs.bodyPartGlobalIdFromLocalId[class][6][
            LibUnicornDNA._getTailPart(_dna)
        ];
    }
}
