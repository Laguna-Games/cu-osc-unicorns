// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from '../libraries/LibUnicornDNA.sol';
import {LibStatCache} from '../libraries/LibStatCache.sol';
import {IUnicornStatCache} from '../interfaces/IUnicornStats.sol';
import {LibGenes} from '../libraries/LibGenes.sol';
import {LibUnicorn} from '../libraries/LibUnicorn.sol';

library LibStats {
    function getPowerScore(uint256 attack, uint256 accuracy) internal pure returns (uint256) {
        uint256 powerAttackScalar = 1;
        uint256 powerAccuracyScalar = 1;
        uint256 powerScalar = 1;
        uint256 finalAttack = attack * powerAttackScalar;
        uint256 finalAccuracy = accuracy * powerAccuracyScalar;
        uint256 power = (finalAttack + finalAccuracy) * powerScalar;
        return power;
    }

    function getSpeedScore(uint256 movementSpeed, uint256 attackSpeed) internal pure returns (uint256) {
        uint256 movementSpeedScalar = 1;
        uint256 attackSpeedScalar = 1;
        uint256 speedScalar = 1;
        uint256 finalMovementSpeed = movementSpeed * movementSpeedScalar;
        uint256 finalAttackSpeed = attackSpeed * attackSpeedScalar;
        uint256 speed = (finalMovementSpeed + finalAttackSpeed) * speedScalar;
        return speed;
    }

    function getEnduranceScore(uint256 vitality, uint256 defense) internal pure returns (uint256) {
        uint256 vitalityScalar = 1;
        uint256 defenseScalar = 1;
        uint256 enduranceScalar = 1;
        uint256 finalVitality = vitality * vitalityScalar;
        uint256 finalDefense = defense * defenseScalar;
        uint256 endurance = (finalVitality + finalDefense) * enduranceScalar;
        return endurance;
    }

    function getIntelligenceScore(uint256 magic, uint256 resistance) internal pure returns (uint256) {
        uint256 magicScalar = 1;
        uint256 resistanceScalar = 1;
        uint256 intelligenceScalar = 1;
        uint256 finalMagic = magic * magicScalar;
        uint256 finalResistance = resistance * resistanceScalar;
        uint256 intelligence = (finalMagic + finalResistance) * intelligenceScalar;
        return intelligence;
    }

    //  TODO: move _deriveStat into a library and convert all of these functions
    function getAttack(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_ATTACK);
    }

    function getAccuracy(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_ACCURACY);
    }

    function getMovementSpeed(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_MOVE_SPEED);
    }

    function getAttackSpeed(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_ATTACK_SPEED);
    }

    function getDefense(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_DEFENSE);
    }

    function getVitality(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_VITALITY);
    }

    function getResistance(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_RESISTANCE);
    }

    function getMagic(uint256 _dna) internal view returns (uint256) {
        return _deriveStat(_dna, LibUnicornDNA.STAT_MAGIC);
    }

    struct OnDemandStatData {
        uint256[18] geneId;
        uint256[] addition;
        uint256[] multiplier;
    }

    function generateOnDemandStruct(uint256 dna) private pure returns (OnDemandStatData memory) {
        return
            OnDemandStatData({
                geneId: [
                    LibUnicornDNA._getBodyMajorGene(dna),
                    LibUnicornDNA._getBodyMidGene(dna),
                    LibUnicornDNA._getBodyMinorGene(dna),
                    LibUnicornDNA._getFaceMajorGene(dna),
                    LibUnicornDNA._getFaceMidGene(dna),
                    LibUnicornDNA._getFaceMinorGene(dna),
                    LibUnicornDNA._getHoovesMajorGene(dna),
                    LibUnicornDNA._getHoovesMidGene(dna),
                    LibUnicornDNA._getHoovesMinorGene(dna),
                    LibUnicornDNA._getHornMajorGene(dna),
                    LibUnicornDNA._getHornMidGene(dna),
                    LibUnicornDNA._getHornMinorGene(dna),
                    LibUnicornDNA._getManeMajorGene(dna),
                    LibUnicornDNA._getManeMidGene(dna),
                    LibUnicornDNA._getManeMinorGene(dna),
                    LibUnicornDNA._getTailMajorGene(dna),
                    LibUnicornDNA._getTailMidGene(dna),
                    LibUnicornDNA._getTailMinorGene(dna)
                ],
                addition: new uint256[](9),
                multiplier: new uint256[](9)
            });
    }

    function getStats(
        uint256 _dna
    )
        internal
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
        LibUnicornDNA.enforceDNAVersionMatch(_dna);
        uint8 class = LibUnicornDNA._getClass(_dna);
        // uint256 age = ;
        if (
            LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_BABY ||
            LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_ADULT
        ) {
            //  no stats for eggs
            LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
            LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();

            OnDemandStatData memory data = generateOnDemandStruct(_dna);

            for (uint i = 0; i < 18; ++i) {
                //  loop through each gene
                if (gs.geneApplicationById[data.geneId[i]] == 1) {
                    //  if the gene is a multiplier...
                    data.multiplier[gs.geneBonusStatByGeneId[data.geneId[i]][1]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][1]; //  Add bonus 1 to corresponding stat in the multiplier array
                    data.multiplier[gs.geneBonusStatByGeneId[data.geneId[i]][2]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][2]; //  Add bonus 2 to corresponding stat in the multiplier array
                    data.multiplier[gs.geneBonusStatByGeneId[data.geneId[i]][3]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][3]; //  Add bonus 3 to corresponding stat in the multiplier array
                } else if (gs.geneApplicationById[data.geneId[i]] == 2) {
                    //  if the gene is an adder...
                    data.addition[gs.geneBonusStatByGeneId[data.geneId[i]][1]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][1]; //  Add bonus 1 to corresponding stat in the adder array
                    data.addition[gs.geneBonusStatByGeneId[data.geneId[i]][2]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][2]; //  Add bonus 2 to corresponding stat in the adder array
                    data.addition[gs.geneBonusStatByGeneId[data.geneId[i]][3]] += gs.geneBonusValueByGeneId[
                        data.geneId[i]
                    ][3]; //  Add bonus 3 to corresponding stat in the adder array
                }
            }

            attack = us.baseStats[class][LibUnicornDNA.STAT_ATTACK];
            accuracy = us.baseStats[class][LibUnicornDNA.STAT_ACCURACY];
            movementSpeed = us.baseStats[class][LibUnicornDNA.STAT_MOVE_SPEED];
            attackSpeed = us.baseStats[class][LibUnicornDNA.STAT_ATTACK_SPEED];
            defense = us.baseStats[class][LibUnicornDNA.STAT_DEFENSE];
            vitality = us.baseStats[class][LibUnicornDNA.STAT_VITALITY];
            resistance = us.baseStats[class][LibUnicornDNA.STAT_RESISTANCE];
            magic = us.baseStats[class][LibUnicornDNA.STAT_MAGIC];

            if (LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_ADULT) {
                //  add 20% to adults
                attack += attack / 5;
                accuracy += accuracy / 5;
                movementSpeed += movementSpeed / 5;
                attackSpeed += attackSpeed / 5;
                defense += defense / 5;
                vitality += vitality / 5;
                resistance += resistance / 5;
                magic += magic / 5;
            }

            //  compute each stat
            attack += data.addition[LibUnicornDNA.STAT_ATTACK];
            attack += (attack * data.multiplier[LibUnicornDNA.STAT_ATTACK]) / 100;
            if (attack > 1000) attack = 1000;

            accuracy += data.addition[LibUnicornDNA.STAT_ACCURACY];
            accuracy += (accuracy * data.multiplier[LibUnicornDNA.STAT_ACCURACY]) / 100;
            if (accuracy > 1000) accuracy = 1000;

            movementSpeed += data.addition[LibUnicornDNA.STAT_MOVE_SPEED];
            movementSpeed += (movementSpeed * data.multiplier[LibUnicornDNA.STAT_MOVE_SPEED]) / 100;
            if (movementSpeed > 1000) movementSpeed = 1000;

            attackSpeed += data.addition[LibUnicornDNA.STAT_ATTACK_SPEED];
            attackSpeed += (attackSpeed * data.multiplier[LibUnicornDNA.STAT_ATTACK_SPEED]) / 100;
            if (attackSpeed > 1000) attackSpeed = 1000;

            defense += data.addition[LibUnicornDNA.STAT_DEFENSE];
            defense += (defense * data.multiplier[LibUnicornDNA.STAT_DEFENSE]) / 100;
            if (defense > 1000) defense = 1000;

            vitality += data.addition[LibUnicornDNA.STAT_VITALITY];
            vitality += (vitality * data.multiplier[LibUnicornDNA.STAT_VITALITY]) / 100;
            if (vitality > 1000) vitality = 1000;

            resistance += data.addition[LibUnicornDNA.STAT_RESISTANCE];
            resistance += (resistance * data.multiplier[LibUnicornDNA.STAT_RESISTANCE]) / 100;
            if (resistance > 1000) resistance = 1000;

            magic += data.addition[LibUnicornDNA.STAT_MAGIC];
            magic += (magic * data.multiplier[LibUnicornDNA.STAT_MAGIC]) / 100;
            if (magic > 1000) magic = 1000;
        }
    }

    function _deriveStat(uint256 _dna, uint256 _statId) internal view returns (uint256) {
        LibUnicornDNA.enforceDNAVersionMatch(_dna);
        require(
            LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_ADULT ||
                LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_BABY,
            'LibStats: Invalid DNA Lifecycle Stage, must be baby or adult'
        );

        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        uint256 class = LibUnicornDNA._getClass(_dna);
        uint256 statBase = LibUnicorn.unicornStorage().baseStats[class][_statId];

        if (LibUnicornDNA._getLifecycleStage(_dna) == LibUnicornDNA.LIFECYCLE_ADULT) {
            statBase += (statBase / 5); //  add 20%
        }

        uint256[18] memory geneId = [
            LibUnicornDNA._getBodyMajorGene(_dna),
            LibUnicornDNA._getBodyMidGene(_dna),
            LibUnicornDNA._getBodyMinorGene(_dna),
            LibUnicornDNA._getFaceMajorGene(_dna),
            LibUnicornDNA._getFaceMidGene(_dna),
            LibUnicornDNA._getFaceMinorGene(_dna),
            LibUnicornDNA._getHoovesMajorGene(_dna),
            LibUnicornDNA._getHoovesMidGene(_dna),
            LibUnicornDNA._getHoovesMinorGene(_dna),
            LibUnicornDNA._getHornMajorGene(_dna),
            LibUnicornDNA._getHornMidGene(_dna),
            LibUnicornDNA._getHornMinorGene(_dna),
            LibUnicornDNA._getManeMajorGene(_dna),
            LibUnicornDNA._getManeMidGene(_dna),
            LibUnicornDNA._getManeMinorGene(_dna),
            LibUnicornDNA._getTailMajorGene(_dna),
            LibUnicornDNA._getTailMidGene(_dna),
            LibUnicornDNA._getTailMinorGene(_dna)
        ];

        uint256 addition = 0;
        uint256 multiplier = 0;

        for (uint256 i = 0; i < 18; ++i) {
            for (uint256 j = 1; j <= 3; ++j) {
                if (gs.geneBonusStatByGeneId[geneId[i]][j] == _statId) {
                    if (gs.geneApplicationById[geneId[i]] == 1) {
                        multiplier += gs.geneBonusValueByGeneId[geneId[i]][j];
                    } else if (gs.geneApplicationById[geneId[i]] == 2) {
                        addition += gs.geneBonusValueByGeneId[geneId[i]][j];
                    }
                }
            }
        }

        uint256 stat = statBase + addition;
        stat += ((stat * multiplier) / 100);
        return (stat <= 1000) ? stat : 1000;
    }

    function getPowerScoreByTokenId(uint256 tokenId) internal view returns (uint256) {
        IUnicornStatCache.Stats memory enhancedStats = LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
        return getPowerScore(enhancedStats.attack, enhancedStats.accuracy);
    }

    function getSpeedScoreByTokenId(uint256 tokenId) internal view returns (uint256) {
        IUnicornStatCache.Stats memory enhancedStats = LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
        return getSpeedScore(enhancedStats.moveSpeed, enhancedStats.attackSpeed);
    }

    function getEnduranceScoreByTokenId(uint256 tokenId) internal view returns (uint256) {
        IUnicornStatCache.Stats memory enhancedStats = LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
        return getEnduranceScore(enhancedStats.vitality, enhancedStats.defense);
    }

    function getIntelligenceScoreByTokenId(uint256 tokenId) internal view returns (uint256) {
        IUnicornStatCache.Stats memory enhancedStats = LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
        return getIntelligenceScore(enhancedStats.magic, enhancedStats.resistance);
    }
}
