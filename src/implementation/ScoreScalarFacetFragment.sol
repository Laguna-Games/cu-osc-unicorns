// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract ScoreScalarFacetFragment {
    //POWER
    function getPowerScalar() public pure returns (uint256) {}

    function getPowerAttackScalar() public pure returns (uint256) {}

    function getPowerAccuracyScalar() public pure returns (uint256) {}

    //SPEED
    function getSpeedScalar() public pure returns (uint256) {}

    function getSpeedMovespeedScalar() public pure returns (uint256) {}

    function getSpeedAttackspeedScalar() public pure returns (uint256) {}

    //ENDURANCE
    function getEnduranceScalar() public pure returns (uint256) {}

    function getEnduranceVitalityScalar() public pure returns (uint256) {}

    function getEnduranceDefenseScalar() public pure returns (uint256) {}

    //INTELLIGENCE
    function getIntelligenceScalar() public pure returns (uint256) {}

    function getIntelligenceMagicScalar() public pure returns (uint256) {}

    function getIntelligenceResistanceScalar() public pure returns (uint256) {}
}
