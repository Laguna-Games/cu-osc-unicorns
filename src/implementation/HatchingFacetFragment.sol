// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract HatchingFacetFragment {
    event HatchingRNGRequested(uint256 indexed roundTripId, bytes32 indexed vrfRequestId, address indexed playerWallet);
    event HatchingRNGRequestedV2(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed owner,
        address playerWallet
    );
    event HatchingReadyForTokenURI(uint256 indexed roundTripId, address indexed playerWallet);
    event HatchingReadyForTokenURIV2(uint256 indexed roundTripId, address indexed owner, address indexed playerWallet);
    event HatchingComplete(uint256 indexed roundTripId, address indexed playerWallet);
    event HatchingCompleteV2(uint256 indexed roundTripId, address indexed owner, address indexed playerWallet);

    function beginHatchingWithSignature(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

    function beginHatchingGenerateMessageHash(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function retryHatchingWithSignature(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

    function retryHatchingGenerateMessageHash(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function finishHatchingGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function finishHatchingWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes calldata signature
    ) public {}
}
