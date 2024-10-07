// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract TuningFacetFragment {
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
    ) external {}

    function addBaseStatTuning(
        uint256 _geneTier,
        uint256 _upgradeChanceMajor,
        uint256 _upgradeChanceMid,
        uint256 _upgradeChanceMinor
    ) external {}

    function addStatGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight
    ) external {}

    function addClassGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight,
        uint256 _classId
    ) external {}

    function addClassGroupGeneTuning(
        uint256 _geneId,
        uint256 _tier,
        uint256 _upgradedTierId,
        uint256 _application,
        uint256 _weight,
        uint256 _classGroupId
    ) external {}

    function addGeneBonusesTuning(
        uint256 _geneId,
        uint256 _bonus1Stat,
        uint256 _bonus1Value,
        uint256 _bonus2Stat,
        uint256 _bonus2Value,
        uint256 _bonus3Stat,
        uint256 _bonus3Value
    ) external {}

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
    ) external {}
}
