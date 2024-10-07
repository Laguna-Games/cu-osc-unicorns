// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract LimitedEditionFacetFragment {
    function mintLimitedEditionUnicorn(
        uint256 firstNameIndex,
        uint256 lastNameIndex,
        uint8 classId,
        string calldata tokenURI,
        uint256[6] memory bodyPartIds
    ) external {}
}
