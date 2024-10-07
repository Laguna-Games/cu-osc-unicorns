// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract EvolutionFacetFragment {
    event EvolutionRNGRequested(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed playerWallet
    );
    event EvolutionRNGRequestedV2(
        uint256 indexed roundTripId,
        bytes32 indexed vrfRequestId,
        address indexed owner,
        address playerWallet
    );
    event EvolutionReadyForTokenURI(uint256 indexed roundTripId, address indexed playerWallet);
    event EvolutionReadyForTokenURIV2(uint256 indexed roundTripId, address indexed owner, address indexed playerWallet);
    event EvolutionComplete(uint256 indexed roundTripId, address indexed playerWallet);
    event EvolutionCompleteV2(uint256 indexed roundTripId, address indexed owner, address indexed playerWallet);

    // SSS functionality
    function beginEvolutionGenerateMessageHash(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 upgradeBooster,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function beginEvolutionWithSignature(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 upgradeBooster,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function retryEvolutionGenerateMessageHash(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function retryEvolutionWithSignature(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function finishEvolutionGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function finishEvolutionWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}
}
