// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract BreedingFinishFacetFragment {
    event BreedingComplete(uint256 indexed roundTripId, uint256 indexed eggId);
    event BreedingCompleteV2(uint256 indexed roundTripId, uint256 indexed eggId, address indexed owner);
    event UnicornEggCreated(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 indexed childId,
        address indexed breeder
    );
    event UnicornEggCreatedV2(
        uint256 firstParentId,
        uint256 secondParentId,
        uint256 indexed childId,
        address indexed owner,
        address indexed breeder
    );

    //finish breeding
    function finishBreedingWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

    function finishBreedingGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}
}
