// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";

contract TuningFacet {
    //  Add a part definition from the spreadsheet into our contract data
    //  @param _partId The local id of the part (only unique in class-slot scope)
    //  @param _classId Name of the class this part belongs to
    //  @param _slotId Name of the body-part slot this part belongs to
    //  @param _weight Probability of this part being picked in a random draw
    //  @param _mythic If true, this part is of mythic rarity
    //  @param _geneId The uid of a gene that's attached to this body part
    function addBodyPartTuning(
        uint256 _globalPartId, //  globally unique
        uint256 _localPartId, //  unique within class/slot
        uint256 _classId,
        uint256 _slotId,
        uint256 _weight,
        bool _mythic,
        uint256 _geneId
    ) external {
        // TODO: guard against part _id collisions
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        gs.bodyPartLocalIdFromGlobalId[_globalPartId] = _localPartId;
        gs.bodyPartGlobalIdFromLocalId[_classId][_slotId][
            _localPartId
        ] = _globalPartId;
        gs.bodyPartBuckets[_classId][_slotId].push(_globalPartId);
        gs.bodyPartWeight[_globalPartId] = _weight;
        // gs.partWeightSum[_classId][_slotId] += _weight;
        gs.bodyPartIsMythic[_globalPartId] = _mythic;
        gs.bodyPartInheritedGene[_globalPartId] = _geneId;
    }

    function addBaseStatTuning(
        uint256 _geneTier,
        uint256 _upgradeChanceMajor,
        uint256 _upgradeChanceMid,
        uint256 _upgradeChanceMinor
    ) external {
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        gs.geneUpgradeChances[_geneTier][1] = _upgradeChanceMajor;
        gs.geneUpgradeChances[_geneTier][2] = _upgradeChanceMid;
        gs.geneUpgradeChances[_geneTier][3] = _upgradeChanceMinor;
    }

    function addStatGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight
    ) external {
        // TODO: guard against _geneId collisions
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        gs.geneTierById[_geneId] = _tier;
        gs.geneTierUpgradeById[_geneId] = _upgradedTierId;
        gs.geneApplicationById[_geneId] = _application;
        gs.geneWeightById[_geneId] = _weight;

        //  Stat genes apply to all classes
        gs.geneBuckets[0].push(_geneId);
        gs.geneBucketSumWeights[0] += _weight;
        gs.geneBuckets[1].push(_geneId);
        gs.geneBucketSumWeights[1] += _weight;
        gs.geneBuckets[2].push(_geneId);
        gs.geneBucketSumWeights[2] += _weight;
        gs.geneBuckets[3].push(_geneId);
        gs.geneBucketSumWeights[3] += _weight;
        gs.geneBuckets[4].push(_geneId);
        gs.geneBucketSumWeights[4] += _weight;
        gs.geneBuckets[5].push(_geneId);
        gs.geneBucketSumWeights[5] += _weight;
        gs.geneBuckets[6].push(_geneId);
        gs.geneBucketSumWeights[6] += _weight;
        gs.geneBuckets[7].push(_geneId);
        gs.geneBucketSumWeights[7] += _weight;
        gs.geneBuckets[8].push(_geneId);
        gs.geneBucketSumWeights[8] += _weight;
    }

    function addClassGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight,
        uint256 _classId
    ) external {
        require(_classId <= 8, "TuningFacet: Invalid classID");
        // TODO: guard against _geneId collisions
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        gs.geneTierById[_geneId] = _tier;
        gs.geneTierUpgradeById[_geneId] = _upgradedTierId;
        gs.geneApplicationById[_geneId] = _application;
        gs.geneWeightById[_geneId] = _weight;

        //  Stat genes apply to all classes
        gs.geneBuckets[_classId].push(_geneId);
        gs.geneBucketSumWeights[_classId] += _weight;
    }

    function addClassGroupGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight,
        uint256 _classGroupId
    ) external {
        require(_classGroupId <= 2, "TuningFacet: Invalid classgroupId");
        // TODO: guard against _geneId collisions
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        gs.geneTierById[_geneId] = _tier;
        gs.geneTierUpgradeById[_geneId] = _upgradedTierId;
        gs.geneApplicationById[_geneId] = _application;
        gs.geneWeightById[_geneId] = _weight;

        if (_classGroupId == 0) {
            gs.geneBuckets[0].push(_geneId);
            gs.geneBucketSumWeights[0] += _weight;
            gs.geneBuckets[1].push(_geneId);
            gs.geneBucketSumWeights[1] += _weight;
            gs.geneBuckets[2].push(_geneId);
            gs.geneBucketSumWeights[2] += _weight;
        } else if (_classGroupId == 1) {
            gs.geneBuckets[3].push(_geneId);
            gs.geneBucketSumWeights[3] += _weight;
            gs.geneBuckets[4].push(_geneId);
            gs.geneBucketSumWeights[4] += _weight;
            gs.geneBuckets[5].push(_geneId);
            gs.geneBucketSumWeights[5] += _weight;
        } else if (_classGroupId == 2) {
            gs.geneBuckets[6].push(_geneId);
            gs.geneBucketSumWeights[6] += _weight;
            gs.geneBuckets[7].push(_geneId);
            gs.geneBucketSumWeights[7] += _weight;
            gs.geneBuckets[8].push(_geneId);
            gs.geneBucketSumWeights[8] += _weight;
        }
    }

    function addGeneBonusesTuning(
        uint256 _geneId,
        uint256 _bonus1Stat,
        uint256 _bonus1Value,
        uint256 _bonus2Stat,
        uint256 _bonus2Value,
        uint256 _bonus3Stat,
        uint256 _bonus3Value
    ) external {
        LibContractOwner.enforceIsContractOwner();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        if (_bonus1Stat > 0) {
            gs.geneBonusStatByGeneId[_geneId][1] = _bonus1Stat;
            gs.geneBonusValueByGeneId[_geneId][1] = _bonus1Value;
        }

        if (_bonus2Stat > 0) {
            gs.geneBonusStatByGeneId[_geneId][2] = _bonus3Stat;
            gs.geneBonusValueByGeneId[_geneId][2] = _bonus2Value;
        }

        if (_bonus3Stat > 0) {
            gs.geneBonusStatByGeneId[_geneId][3] = _bonus3Stat;
            gs.geneBonusValueByGeneId[_geneId][3] = _bonus3Value;
        }
    }

    function addBaseStats(
        uint256 _classId,
        uint256 _vitality,
        uint256 _attack,
        uint256 _defense,
        uint256 _accuracy,
        uint256 _magic,
        uint256 _resistance,
        uint256 _moveSpeed,
        uint256 _attackSpeed
    ) external {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        LibContractOwner.enforceIsContractOwner();
        us.baseStats[_classId][LibUnicornDNA.STAT_ATTACK] = _attack;
        us.baseStats[_classId][LibUnicornDNA.STAT_ACCURACY] = _accuracy;
        us.baseStats[_classId][LibUnicornDNA.STAT_MOVE_SPEED] = _moveSpeed;
        us.baseStats[_classId][LibUnicornDNA.STAT_ATTACK_SPEED] = _attackSpeed;
        us.baseStats[_classId][LibUnicornDNA.STAT_DEFENSE] = _defense;
        us.baseStats[_classId][LibUnicornDNA.STAT_VITALITY] = _vitality;
        us.baseStats[_classId][LibUnicornDNA.STAT_RESISTANCE] = _resistance;
        us.baseStats[_classId][LibUnicornDNA.STAT_MAGIC] = _magic;
    }
}
