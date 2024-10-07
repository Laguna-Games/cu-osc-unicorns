// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract NamesFacetFragment {
    function lookupFirstName(uint256 _nameId) external view returns (string memory) {}

    function lookupLastName(uint256 _nameId) external view returns (string memory) {}

    function getFullName(uint256 _tokenId) external view returns (string memory) {}

    function getFullNameFromDNA(uint256 _dna) public view returns (string memory) {}
}
