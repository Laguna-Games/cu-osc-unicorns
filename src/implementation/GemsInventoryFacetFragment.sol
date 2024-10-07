// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IUnicornStatCache} from '../interfaces/IUnicornStats.sol';

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract GemsInventoryFacetFragment {
    function equipGemsMessageHash(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds,
        uint256 requestId,
        uint256 blockDeadline
    ) public view virtual returns (bytes32) {}

    function equipGems(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds,
        address signer,
        uint256 requestId,
        uint256 blockDeadline,
        bytes calldata signature
    ) public {}

    function getUnicornInventory(uint256 unicornTokenId) external view returns (uint256[8] memory gemSlots) {}

    function getEquipPreview(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds
    ) external view returns (IUnicornStatCache.Stats memory enhancedStats) {}
}
