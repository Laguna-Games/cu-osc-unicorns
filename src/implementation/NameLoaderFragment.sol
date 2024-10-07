// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract NameLoaderFragment {
    function resetFirstNamesList() external {}

    function resetLastNamesList() external {}

    //  New names are automatically added as valid options for the RNG
    function registerFirstNames(uint256[] memory _ids, string[] memory _names) external {}

    //  New names are automatically added as valid options for the RNG
    function registerLastNames(uint256[] memory _ids, string[] memory _names) public {}

    // Limited edition names are not added to the RNG valid options
    function registerLimitedEditionFirstNames(uint256[] memory _ids, string[] memory _names) external {}

    // Limited edition names are not added to the RNG valid options
    function registerLimitedEditionLastNames(uint256[] memory _ids, string[] memory _names) external {}

    //  If _delete is TRUE, the name will no longer be retrievable, and
    //  any legacy DNA using that name will point to (undefined -> "").
    //  If FALSE, the name will continue to work for existing DNA,
    //  but the RNG will not assign the name to any new tokens.
    function retireFirstName(uint256 _id, bool _delete) external returns (bool) {}

    //  If _delete is TRUE, the name will no longer be retrievable, and
    //  any legacy DNA using that name will point to (undefined -> "").
    //  If FALSE, the name will continue to work for existing DNA,
    //  but the RNG will not assign the name to any new tokens.
    function retireLastName(uint256 _id, bool _delete) external returns (bool) {}
}
