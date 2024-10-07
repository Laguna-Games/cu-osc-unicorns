// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract BreedingBeginFacetFragment {
    event BreedingStarted(uint256 indexed firstParentId, uint256 indexed secondParentId, address indexed breeder);
    event BreedingStartedV2(
        uint256 firstParentId,
        uint256 secondParentId,
        address indexed owner,
        address indexed breeder
    );
    event NewEggRNGRequested(uint256 indexed roundTripId, bytes32 indexed vrfRequestId);
    event NewEggRNGRequestedV2(uint256 indexed roundTripId, bytes32 indexed vrfRequestId, address indexed owner);
    event NewEggReadyForTokenURI(uint256 indexed roundTripId, uint256 indexed eggId, address indexed playerWallet);
    event NewEggReadyForTokenURIV2(
        uint256 indexed roundTripId,
        uint256 indexed eggId,
        address indexed owner,
        address playerWallet
    );

    //Begin breeding
    function beginBreedingWithSignature(
        uint256 roundTripId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

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
    ) public view returns (bytes32) {}
}
