// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract TokenURIFacetFragment {
    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external {}

    function batchSetTokenURI(uint256 startTokenId, string[] calldata _tokenURIs) external {}

    function batchSetTokenURIs(uint256[] calldata _tokenIds, string[] calldata _tokenURIs) external {}
}
