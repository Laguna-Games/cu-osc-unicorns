// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract BatchAirlockFacetFragment {
    event BatchUnlockUnicornsOutOfGame(
        uint256[] tokenIds,
        uint256 indexed requestId,
        address indexed owner,
        address indexed locker
    );

    /// @notice Lock multiple unicorns into game
    /// @param tokenIds The ids of the unicorns to lock
    /// @custom:emits UnicornLockedIntoGame
    /// @custom:emits UnicornLockedIntoGameV2
    function batchLockUnicornsIntoGame(uint256[] memory tokenIds) external {}

    /// @notice Generate one hash to unlock a batch of unicorns at once
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestId The requestId for the batch unlock
    /// @param blockDeadline The block deadline for the batch unlock
    /// @return signature The generated message hash
    function batchUnlockUnicornsOutOfGameGenerateMessageHash(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32 signature) {}

    /// @notice Airlock unlock multiple unicorns at once, with one signature
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestId The requestId for the batch unlock
    /// @param blockDeadline The block deadline for the batch unlock
    /// @param signature The signature for the batch unlock
    /// @custom:emits UnicornUnlockedOutOfGame
    /// @custom:emits UnicornUnlockedOutOfGameV2
    /// @custom:emits BatchUnlockUnicornsOutOfGame
    function batchUnlockUnicornsOutOfGameWithSignature(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}
}
