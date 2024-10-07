// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITwTUnicornInfo} from '../interfaces/ITwTUnicornInfo.sol';

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract StatsFacetFragment {
    function getAttack(uint256 _dna) external view returns (uint256) {}

    function getAccuracy(uint256 _dna) external view returns (uint256) {}

    function getMovementSpeed(uint256 _dna) external view returns (uint256) {}

    function getAttackSpeed(uint256 _dna) external view returns (uint256) {}

    function getDefense(uint256 _dna) external view returns (uint256) {}

    function getVitality(uint256 _dna) external view returns (uint256) {}

    function getResistance(uint256 _dna) external view returns (uint256) {}

    function getMagic(uint256 _dna) external view returns (uint256) {}

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
    {}

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
    {}

    function getMythicPartCount(
        uint256 bodyPartId,
        uint256 facePartId,
        uint256 hornPartId,
        uint256 hoovesPartId,
        uint256 manePartId,
        uint256 tailPartId
    ) internal view returns (uint8 mythicCount) {}

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
    {}

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
    {}

    function getPowerScore(uint256 tokenId) public view returns (uint256) {}

    function getSpeedScore(uint256 tokenId) public view returns (uint256) {}

    function getEnduranceScore(uint256 tokenId) public view returns (uint256) {}

    function getIntelligenceScore(uint256 tokenId) public view returns (uint256) {}

    //  TODO - Deprecate this and use StatCacheFacet.getUnicornStatsBatch()
    function twtGetUnicornInfoMultiple(
        uint256[3] memory tokenIds,
        uint256[] memory relevantStats,
        address user
    ) external view returns (ITwTUnicornInfo.TwTUnicornInfo[] memory unicornInfo) {}
}
