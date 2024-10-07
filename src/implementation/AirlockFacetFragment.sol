// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract AirlockFacetFragment {
    event UnicornLockedIntoGame(uint256 tokenId, address locker);
    event UnicornLockedIntoGameV2(uint256 indexed tokenId, address indexed owner, address indexed locker);
    event UnicornUnlockedOutOfGame(uint256 tokenId, address locker);
    event UnicornUnlockedOutOfGameV2(uint256 indexed tokenId, address indexed owner, address indexed locker);
    event UnicornUnlockedOutOfGameForcefully(uint256 timestamp, uint256 tokenId, address locker);

    function lockUnicornIntoGame(uint256 tokenId) external {}

    function unlockUnicornOutOfGameGenerateMessageHash(
        uint256 tokenId,
        string calldata tokenURI,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    /// @notice Generate multiple message hashes for multiple airlock unlocks
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestIds The request ids for each unlock
    /// @param blockDeadlines The block deadlines for each unlock
    /// @return signatures The generated message hashes
    function multiUnlockUnicornsOutOfGameGenerateMessageHash(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256[] memory requestIds,
        uint256[] memory blockDeadlines
    ) external view returns (bytes32[] memory signatures) {}

    function unlockUnicornOutOfGameWithSignature(
        uint256 tokenId,
        string calldata tokenURI,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    /// @notice Execute multiple airlock unlocks with signatures at once
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestIds The request ids for each unlock
    /// @param blockDeadlines The block deadlines for each unlock
    /// @custom:emits UnicornUnlockedOutOfGame
    /// @custom:emits UnicornUnlockedOutOfGameV2
    function multiUnlockUnicornsOutOfGameWithSignatures(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256[] memory requestIds,
        uint256[] memory blockDeadlines,
        bytes[] memory signatures
    ) external {}

    function forceUnlockUnicornOutOfGame(uint256 tokenId) external pure {}

    function unicornIsTransferable(uint256 tokenId) external view returns (bool) {}
}

contract AirlockFacetFragmentTestnet is AirlockFacetFragment {
    function setForceUnlockUnicornCooldown(uint256 cooldownSeconds) external {}

    function getForceUnlockUnicornCooldown() external view returns (uint256) {}

    function unicornLastForceUnlock(uint256 tokenId) external view returns (uint256) {}

    function unicornIsCoolingDown(uint256 tokenId) external view returns (bool) {}
}
