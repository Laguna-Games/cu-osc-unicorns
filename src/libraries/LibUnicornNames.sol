// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from './LibUnicornDNA.sol';

/// @custom:storage-location erc7201:games.laguna.LibUnicornNames
library LibUnicornNames {
    //  @dev Storage slot for Unicorn Name Storage
    bytes32 internal constant STORAGE_SLOT_POSITION =
        keccak256(abi.encode(uint256(keccak256('games.laguna.LibUnicornNames')) - 1)) & ~bytes32(uint256(0xff));

    struct UnicornNameStorage {
        // nameIndex -> name string
        mapping(uint256 index => string name) firstNamesList;
        mapping(uint256 index => string name) lastNamesList;
        // Names which can be chosen by RNG for new lands (unordered)
        uint256[] validFirstNames;
        uint256[] validLastNames;
    }

    function unicornNameStorage() internal pure returns (UnicornNameStorage storage uns) {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            uns.slot := position
        }
    }

    function _lookupFirstName(uint256 _nameId) internal view returns (string memory) {
        return unicornNameStorage().firstNamesList[_nameId];
    }

    function _lookupLastName(uint256 _nameId) internal view returns (string memory) {
        return unicornNameStorage().lastNamesList[_nameId];
    }

    function _getFullName(uint256 _tokenId) internal view returns (string memory) {
        return _getFullNameFromDNA(LibUnicornDNA._getDNA(_tokenId));
    }

    function _getFullNameFromDNA(uint256 _dna) internal view returns (string memory) {
        LibUnicornDNA.enforceDNAVersionMatch(_dna);
        UnicornNameStorage storage uns = unicornNameStorage();

        //  check if either first or last name is "" - avoid extra whitespace
        if (LibUnicornDNA._getFirstNameIndex(_dna) == 1) {
            return uns.lastNamesList[LibUnicornDNA._getLastNameIndex(_dna)];
        } else if (LibUnicornDNA._getLastNameIndex(_dna) == 1) {
            return uns.firstNamesList[LibUnicornDNA._getFirstNameIndex(_dna)];
        }

        return
            string(
                abi.encodePacked(
                    uns.firstNamesList[LibUnicornDNA._getFirstNameIndex(_dna)],
                    ' ',
                    uns.lastNamesList[LibUnicornDNA._getLastNameIndex(_dna)]
                )
            );
    }

    ///@notice Obtains random names from the valid ones.
    ///@dev Will throw if there are no validFirstNames or validLastNames
    ///@param randomnessFirstName at least 10 bits of randomness
    ///@param randomnessLastName at least 10 bits of randomness
    function _getRandomName(
        uint256 randomnessFirstName,
        uint256 randomnessLastName
    ) internal view returns (uint256[2] memory) {
        UnicornNameStorage storage uns = unicornNameStorage();
        require(uns.validFirstNames.length > 0, 'NamesFacet: First-name list is empty');
        require(uns.validLastNames.length > 0, 'NamesFacet: Last-name list is empty');
        return [
            uns.validFirstNames[(randomnessFirstName % uns.validFirstNames.length)],
            uns.validLastNames[(randomnessLastName % uns.validLastNames.length)]
        ];
    }

    function _firstNameIsAssignable(uint256 firstNameIndex) internal view returns (bool isAssignable) {
        UnicornNameStorage storage uns = unicornNameStorage();
        isAssignable = false;
        for (uint256 i = 0; i < uns.validFirstNames.length; i++) {
            if (uns.validFirstNames[i] == firstNameIndex) {
                isAssignable = true;
            }
        }
        return isAssignable;
    }

    function _lastNameIsAssignable(uint256 lastNameIndex) internal view returns (bool isAssignable) {
        UnicornNameStorage storage uns = unicornNameStorage();
        isAssignable = false;
        for (uint256 i = 0; i < uns.validLastNames.length && !isAssignable; i++) {
            if (uns.validLastNames[i] == lastNameIndex) {
                isAssignable = true;
            }
        }
        return isAssignable;
    }
}
