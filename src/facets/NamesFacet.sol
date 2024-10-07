// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornNames} from '../libraries/LibUnicornNames.sol';

contract NamesFacet {
    function lookupFirstName(uint256 _nameId) external view returns (string memory) {
        return LibUnicornNames._lookupFirstName(_nameId);
    }

    function lookupLastName(uint256 _nameId) external view returns (string memory) {
        return LibUnicornNames._lookupLastName(_nameId);
    }

    function getFullName(uint256 _tokenId) external view returns (string memory) {
        return LibUnicornNames._getFullName(_tokenId);
    }

    function getFullNameFromDNA(uint256 _dna) public view returns (string memory) {
        return LibUnicornNames._getFullNameFromDNA(_dna);
    }
}
