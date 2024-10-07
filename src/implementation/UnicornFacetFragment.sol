// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract UnicornFacetFragment {
    function batchBurnFrom(uint256[] memory tokenIds, address owner) external {}

    function batchSacrificeUnicorns(uint256[] memory tokenIds, address owner) external {}
}
