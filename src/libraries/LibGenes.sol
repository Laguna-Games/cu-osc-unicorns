// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @custom:storage-location erc7201:games.laguna.cryptounicorns.LibGenes
library LibGenes {
    bytes32 internal constant STORAGE_SLOT_POSITION =
        keccak256(abi.encode(uint256(keccak256('games.laguna.cryptounicorns.LibGenes')) - 1)) & ~bytes32(uint256(0xff));

    struct GeneStorage {
        // [geneTier][geneDominance] => chance to upgrade [0-100]
        mapping(uint256 geneTier => mapping(uint256 geneDominance => uint256 upgradeChance)) geneUpgradeChances;
        // [geneId] => tier of the gene [1-6]
        mapping(uint256 geneId => uint256 tier) geneTierById;
        // [geneId] => id of the next tier version of the gene
        mapping(uint256 geneId => uint256 nextGene) geneTierUpgradeById;
        // [geneId] => how the bonuses are applied (1 = multiply, 2 = add)
        mapping(uint256 geneId => uint256 application) geneApplicationById;
        // [classId] => List of available gene globalIds for that class
        mapping(uint256 classId => uint256[] globalIds) geneBuckets;
        // [classId] => sum of weights in a geneBucket
        mapping(uint256 classId => uint256 bucketSum) geneBucketSumWeights;
        // uint256 geneWeightSum;
        mapping(uint256 geneId => uint256 weight) geneWeightById;
        //  [geneId][geneBonusSlot] => statId to affect
        mapping(uint256 geneId => mapping(uint256 geneBonusSlot => uint256 statId)) geneBonusStatByGeneId;
        //  [geneId][geneBonusSlot] => increase amount (percentages are scaled * 100)
        mapping(uint256 geneId => mapping(uint256 geneBonusSlot => uint256 value)) geneBonusValueByGeneId;
        //  [globalPartId] => localPartId
        mapping(uint256 globalPartId => uint256 localPartId) bodyPartLocalIdFromGlobalId;
        //  [globalPartId] => true if mythic
        mapping(uint256 globalPartId => bool isMythic) bodyPartIsMythic;
        //  [globalPartId] => globalPartId of next tier version of the gene
        mapping(uint256 globalPartId => uint256 geneId) bodyPartInheritedGene;
        // [ClassId][PartSlotId] => globalIds[] - this is how we randomize slots
        mapping(uint256 classId => mapping(uint256 partSlotId => uint256[] bucket)) bodyPartBuckets;
        // [ClassId][PartSlotId][localPartId] => globalPartId
        mapping(uint256 classId => mapping(uint256 partSlotId => mapping(uint256 localPartId => uint256 globalPartId))) bodyPartGlobalIdFromLocalId;
        //  [globalPartId] => weight
        mapping(uint256 globalPartId => uint256 weight) bodyPartWeight;
    }

    function geneStorage() internal pure returns (GeneStorage storage ss) {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            ss.slot := position
        }
    }
}
