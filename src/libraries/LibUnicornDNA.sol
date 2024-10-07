// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibBin} from "../../lib/cu-osc-common/src/libraries/LibBin.sol";
import {LibHatching} from "./LibHatching.sol";
import {LibUnicorn} from "./LibUnicorn.sol";
import {LibGenes} from "./LibGenes.sol";

/// @custom:storage-location erc7201:games.laguna.LibUnicornDNA
library LibUnicornDNA {
    event DNAUpdated(uint256 tokenId, uint256 dna);

    uint256 internal constant STAT_ATTACK = 1;
    uint256 internal constant STAT_ACCURACY = 2;
    uint256 internal constant STAT_MOVE_SPEED = 3;
    uint256 internal constant STAT_ATTACK_SPEED = 4;
    uint256 internal constant STAT_DEFENSE = 5;
    uint256 internal constant STAT_VITALITY = 6;
    uint256 internal constant STAT_RESISTANCE = 7;
    uint256 internal constant STAT_MAGIC = 8;

    // uint256 internal constant DNA_VERSION = 1;   // deprecated - use targetDNAVersion()
    uint256 internal constant MAX = type(uint256).max;

    //  version is in bits 0-7 = 0b11111111
    uint256 internal constant DNA_VERSION_MASK = 0xFF;
    //  origin is in bit 8 = 0b100000000
    uint256 internal constant DNA_ORIGIN_MASK = 0x100;
    //  locked is in bit 9 = 0b1000000000
    uint256 internal constant DNA_LOCKED_MASK = 0x200;
    //  limitedEdition is in bit 10 = 0b10000000000
    uint256 internal constant DNA_LIMITEDEDITION_MASK = 0x400;
    //  lifecycleStage is in bits 11-12 = 0b1100000000000
    uint256 internal constant DNA_LIFECYCLESTAGE_MASK = 0x1800;
    //  breedingPoints is in bits 13-16 = 0b11110000000000000
    uint256 internal constant DNA_BREEDINGPOINTS_MASK = 0x1E000;
    //  class is in bits 17-20 = 0b111100000000000000000
    uint256 internal constant DNA_CLASS_MASK = 0x1E0000;
    //  bodyArt is in bits 21-28 = 0b11111111000000000000000000000
    uint256 internal constant DNA_BODYART_MASK = 0x1FE00000;
    //  bodyMajorGene is in bits 29-36 = 0b1111111100000000000000000000000000000
    uint256 internal constant DNA_BODYMAJORGENE_MASK = 0x1FE0000000;
    //  bodyMidGene is in bits 37-44 = 0b111111110000000000000000000000000000000000000
    uint256 internal constant DNA_BODYMIDGENE_MASK = 0x1FE000000000;
    //  bodyMinorGene is in bits 45-52 = 0b11111111000000000000000000000000000000000000000000000
    uint256 internal constant DNA_BODYMINORGENE_MASK = 0x1FE00000000000;
    //  faceArt is in bits 53-60 = 0b1111111100000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_FACEART_MASK = 0x1FE0000000000000;
    //  faceMajorGene is in bits 61-68 = 0b111111110000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_FACEMAJORGENE_MASK = 0x1FE000000000000000;
    //  faceMidGene is in bits 69-76 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_FACEMIDGENE_MASK = 0x1FE00000000000000000;
    //  faceMinorGene is in bits 77-84 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_FACEMINORGENE_MASK = 0x1FE0000000000000000000;
    //  hornArt is in bits 85-92 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HORNART_MASK = 0x1FE000000000000000000000;
    //  hornMajorGene is in bits 93-100 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HORNMAJORGENE_MASK =
        0x1FE00000000000000000000000;
    //  hornMidGene is in bits 101-108 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HORNMIDGENE_MASK =
        0x1FE0000000000000000000000000;
    //  hornMinorGene is in bits 109-116 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HORNMINORGENE_MASK =
        0x1FE000000000000000000000000000;
    //  hoovesArt is in bits 117-124 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HOOVESART_MASK =
        0x1FE00000000000000000000000000000;
    //  hoovesMajorGene is in bits 125-132 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HOOVESMAJORGENE_MASK =
        0x1FE0000000000000000000000000000000;
    //  hoovesMidGene is in bits 133-140 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HOOVESMIDGENE_MASK =
        0x1FE000000000000000000000000000000000;
    //  hoovesMinorGene is in bits 141-148 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_HOOVESMINORGENE_MASK =
        0x1FE00000000000000000000000000000000000;
    //  maneArt is in bits 149-156 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_MANEART_MASK =
        0x001FE0000000000000000000000000000000000000;
    //  maneMajorGene is in bits 157-164 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_MANEMAJORGENE_MASK =
        0x1FE000000000000000000000000000000000000000;
    //  maneMidGene is in bits 165-172 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_MANEMIDGENE_MASK =
        0x1FE00000000000000000000000000000000000000000;
    //  maneMinorGene is in bits 173-180 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_MANEMINORGENE_MASK =
        0x1FE0000000000000000000000000000000000000000000;
    //  tailArt is in bits 181-188 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_TAILART_MASK =
        0x1FE000000000000000000000000000000000000000000000;
    //  tailMajorGene is in bits 189-196 = 0b11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_TAILMAJORGENE_MASK =
        0x1FE00000000000000000000000000000000000000000000000;
    //  tailMidGene is in bits 197-204 = 0b1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_TAILMIDGENE_MASK =
        0x1FE0000000000000000000000000000000000000000000000000;
    //  tailMinorGene is in bits 205-212 = 0b111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_TAILMINORGENE_MASK =
        0x1FE000000000000000000000000000000000000000000000000000;

    //  firstName index is in bits 213-222 = 0b1111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_FIRST_NAME =
        0x7FE00000000000000000000000000000000000000000000000000000;
    //  lastName index is in bits 223-232 = 0b11111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    uint256 internal constant DNA_LAST_NAME =
        0x1FF80000000000000000000000000000000000000000000000000000000;

    uint8 internal constant LIFECYCLE_EGG = 0;
    uint8 internal constant LIFECYCLE_BABY = 1;
    uint8 internal constant LIFECYCLE_ADULT = 2;

    uint8 internal constant DEFAULT_BREEDING_POINTS = 8;

    //  @dev Storage slot for Unicorn DNA
    bytes32 internal constant DNA_STORAGE_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.LibUnicornDNA")) - 1)
        ) & ~bytes32(uint256(0xff));

    struct LibDNAStorage {
        uint256 targetDNAVersion;
        mapping(uint256 => uint256) cachedDNA; //  This is used during RNG when DNA can be volatile
        mapping(uint256 => uint256) dna; // DO NOT ACCESS DIRECTLY! Use LibUnicornDNA
    }

    function dnaStorage() internal pure returns (LibDNAStorage storage lds) {
        bytes32 position = DNA_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lds.slot := position
        }
    }

    function _getDNA(uint256 _tokenId) internal view returns (uint256) {
        LibDNAStorage storage lds = dnaStorage();
        if (lds.cachedDNA[_tokenId] > 0) {
            return lds.cachedDNA[_tokenId];
        } else if (LibHatching.shouldUsePredictiveDNA(_tokenId)) {
            return LibHatching.predictBabyDNA(_tokenId);
        }

        return lds.dna[_tokenId];
    }

    function _getCanonicalDNA(
        uint256 _tokenId
    ) internal view returns (uint256) {
        return dnaStorage().dna[_tokenId];
    }

    function _setDNA(
        uint256 _tokenId,
        uint256 _dna
    ) internal returns (uint256) {
        require(_dna > 0, "LibUnicornDNA: cannot set 0 DNA");
        dnaStorage().dna[_tokenId] = _dna;
        emit DNAUpdated(_tokenId, _dna);
        return _dna;
    }

    function _getBirthday(uint256 _tokenId) internal view returns (uint256) {
        if (LibHatching.shouldUsePredictiveDNA(_tokenId)) {
            return LibHatching.predictBabyBirthday(_tokenId);
        }
        return LibUnicorn.unicornStorage().hatchBirthday[_tokenId];
    }

    //  The currently supported DNA version - all DNA should be at this number,
    //  or lower if migrating...
    function _targetDNAVersion() internal view returns (uint256) {
        return dnaStorage().targetDNAVersion;
    }

    function _setVersion(
        uint256 _dna,
        uint256 _value
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _value, DNA_VERSION_MASK);
    }

    function _getVersion(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_VERSION_MASK);
    }

    function enforceDNAVersionMatch(uint256 _dna) internal view {
        require(
            _getVersion(_dna) == _targetDNAVersion(),
            "LibUnicornDNA: Invalid DNA version"
        );
    }

    function _setOrigin(
        uint256 _dna,
        bool _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_ORIGIN_MASK);
    }

    function _getOrigin(uint256 _dna) internal pure returns (bool) {
        return LibBin.extractBool(_dna, DNA_ORIGIN_MASK);
    }

    function _setGameLocked(
        uint256 _dna,
        bool _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_LOCKED_MASK);
    }

    function _getGameLocked(uint256 _dna) internal pure returns (bool) {
        return LibBin.extractBool(_dna, DNA_LOCKED_MASK);
    }

    function _setLimitedEdition(
        uint256 _dna,
        bool _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_LIMITEDEDITION_MASK);
    }

    function _getLimitedEdition(uint256 _dna) internal pure returns (bool) {
        return LibBin.extractBool(_dna, DNA_LIMITEDEDITION_MASK);
    }

    function _setLifecycleStage(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_LIFECYCLESTAGE_MASK);
    }

    function _getLifecycleStage(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_LIFECYCLESTAGE_MASK);
    }

    function _setBreedingPoints(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_BREEDINGPOINTS_MASK);
    }

    function _getBreedingPoints(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_BREEDINGPOINTS_MASK);
    }

    function _setClass(
        uint256 _dna,
        uint8 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, uint256(_val), DNA_CLASS_MASK);
    }

    function _getClass(uint256 _dna) internal pure returns (uint8) {
        return uint8(LibBin.extract(_dna, DNA_CLASS_MASK));
    }

    function _multiSetBody(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(_dna, _minorGene, DNA_BODYMINORGENE_MASK),
                        _midGene,
                        DNA_BODYMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_BODYMAJORGENE_MASK
                ),
                _part,
                DNA_BODYART_MASK
            );
    }

    function _inheritBody(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetBody(
                _dna,
                _getBodyPart(_inherited),
                _getBodyMajorGene(_inherited),
                _getBodyMidGene(_inherited),
                _getBodyMinorGene(_inherited)
            );
    }

    function _setBodyPart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_BODYART_MASK);
    }

    function _getBodyPart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_BODYART_MASK);
    }

    function _setBodyMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_BODYMAJORGENE_MASK);
    }

    function _getBodyMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_BODYMAJORGENE_MASK);
    }

    function _setBodyMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_BODYMIDGENE_MASK);
    }

    function _getBodyMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_BODYMIDGENE_MASK);
    }

    function _setBodyMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_BODYMINORGENE_MASK);
    }

    function _getBodyMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_BODYMINORGENE_MASK);
    }

    function _multiSetFace(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(_dna, _minorGene, DNA_FACEMINORGENE_MASK),
                        _midGene,
                        DNA_FACEMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_FACEMAJORGENE_MASK
                ),
                _part,
                DNA_FACEART_MASK
            );
    }

    function _inheritFace(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetFace(
                _dna,
                _getFacePart(_inherited),
                _getFaceMajorGene(_inherited),
                _getFaceMidGene(_inherited),
                _getFaceMinorGene(_inherited)
            );
    }

    function _setFacePart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_FACEART_MASK);
    }

    function _getFacePart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_FACEART_MASK);
    }

    function _setFaceMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_FACEMAJORGENE_MASK);
    }

    function _getFaceMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_FACEMAJORGENE_MASK);
    }

    function _setFaceMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_FACEMIDGENE_MASK);
    }

    function _getFaceMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_FACEMIDGENE_MASK);
    }

    function _setFaceMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_FACEMINORGENE_MASK);
    }

    function _getFaceMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_FACEMINORGENE_MASK);
    }

    function _multiSetHooves(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(
                            _dna,
                            _minorGene,
                            DNA_HOOVESMINORGENE_MASK
                        ),
                        _midGene,
                        DNA_HOOVESMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_HOOVESMAJORGENE_MASK
                ),
                _part,
                DNA_HOOVESART_MASK
            );
    }

    function _inheritHooves(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetHooves(
                _dna,
                _getHoovesPart(_inherited),
                _getHoovesMajorGene(_inherited),
                _getHoovesMidGene(_inherited),
                _getHoovesMinorGene(_inherited)
            );
    }

    function _setHoovesPart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HOOVESART_MASK);
    }

    function _getHoovesPart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HOOVESART_MASK);
    }

    function _setHoovesMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HOOVESMAJORGENE_MASK);
    }

    function _getHoovesMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HOOVESMAJORGENE_MASK);
    }

    function _setHoovesMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HOOVESMIDGENE_MASK);
    }

    function _getHoovesMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HOOVESMIDGENE_MASK);
    }

    function _setHoovesMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HOOVESMINORGENE_MASK);
    }

    function _getHoovesMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HOOVESMINORGENE_MASK);
    }

    function _multiSetHorn(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(_dna, _minorGene, DNA_HORNMINORGENE_MASK),
                        _midGene,
                        DNA_HORNMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_HORNMAJORGENE_MASK
                ),
                _part,
                DNA_HORNART_MASK
            );
    }

    function _inheritHorn(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetHorn(
                _dna,
                _getHornPart(_inherited),
                _getHornMajorGene(_inherited),
                _getHornMidGene(_inherited),
                _getHornMinorGene(_inherited)
            );
    }

    function _setHornPart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HORNART_MASK);
    }

    function _getHornPart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HORNART_MASK);
    }

    function _setHornMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HORNMAJORGENE_MASK);
    }

    function _getHornMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HORNMAJORGENE_MASK);
    }

    function _setHornMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HORNMIDGENE_MASK);
    }

    function _getHornMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HORNMIDGENE_MASK);
    }

    function _setHornMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_HORNMINORGENE_MASK);
    }

    function _getHornMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_HORNMINORGENE_MASK);
    }

    function _multiSetMane(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(_dna, _minorGene, DNA_MANEMINORGENE_MASK),
                        _midGene,
                        DNA_MANEMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_MANEMAJORGENE_MASK
                ),
                _part,
                DNA_MANEART_MASK
            );
    }

    function _inheritMane(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetMane(
                _dna,
                _getManePart(_inherited),
                _getManeMajorGene(_inherited),
                _getManeMidGene(_inherited),
                _getManeMinorGene(_inherited)
            );
    }

    function _setManePart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_MANEART_MASK);
    }

    function _getManePart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_MANEART_MASK);
    }

    function _setManeMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_MANEMAJORGENE_MASK);
    }

    function _getManeMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_MANEMAJORGENE_MASK);
    }

    function _setManeMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_MANEMIDGENE_MASK);
    }

    function _getManeMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_MANEMIDGENE_MASK);
    }

    function _setManeMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_MANEMINORGENE_MASK);
    }

    function _getManeMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_MANEMINORGENE_MASK);
    }

    function _multiSetTail(
        uint256 _dna,
        uint256 _part,
        uint256 _majorGene,
        uint256 _midGene,
        uint256 _minorGene
    ) internal pure returns (uint256) {
        return
            LibBin.splice(
                LibBin.splice(
                    LibBin.splice(
                        LibBin.splice(_dna, _minorGene, DNA_TAILMINORGENE_MASK),
                        _midGene,
                        DNA_TAILMIDGENE_MASK
                    ),
                    _majorGene,
                    DNA_TAILMAJORGENE_MASK
                ),
                _part,
                DNA_TAILART_MASK
            );
    }

    function _inheritTail(
        uint256 _dna,
        uint256 _inherited
    ) internal pure returns (uint256) {
        return
            _multiSetTail(
                _dna,
                _getTailPart(_inherited),
                _getTailMajorGene(_inherited),
                _getTailMidGene(_inherited),
                _getTailMinorGene(_inherited)
            );
    }

    function _setTailPart(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_TAILART_MASK);
    }

    function _getTailPart(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_TAILART_MASK);
    }

    function _setTailMajorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_TAILMAJORGENE_MASK);
    }

    function _getTailMajorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_TAILMAJORGENE_MASK);
    }

    function _setTailMidGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_TAILMIDGENE_MASK);
    }

    function _getTailMidGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_TAILMIDGENE_MASK);
    }

    function _setTailMinorGene(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_TAILMINORGENE_MASK);
    }

    function _getTailMinorGene(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_TAILMINORGENE_MASK);
    }

    function _setFirstNameIndex(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_FIRST_NAME);
    }

    function _getFirstNameIndex(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_FIRST_NAME);
    }

    function _setLastNameIndex(
        uint256 _dna,
        uint256 _val
    ) internal pure returns (uint256) {
        return LibBin.splice(_dna, _val, DNA_LAST_NAME);
    }

    function _getLastNameIndex(uint256 _dna) internal pure returns (uint256) {
        return LibBin.extract(_dna, DNA_LAST_NAME);
    }

    //  @return bodyPartIds - An ordered array of bodypart globalIds [body, face, horn, hooves, mane, tail]
    //  @return geneIds - An ordered array of geen ids [
    // bodyMajor, bodyMid, bodyMinor,
    // faceMajor, faceMid, faceMinor,
    // hornMajor, hornMid, hornMinor,
    // hoovesMajor, hoovesMid, hoovesMinor,
    // maneMajor, maneMid, maneMinor,
    // tailMajor, tailMid, tailMinor]
    function _getGeneMapFromDNA(
        uint256 _dna
    )
        internal
        view
        returns (uint256[6] memory parts, uint256[18] memory genes)
    {
        parts = [uint256(0), 0, 0, 0, 0, 0];
        genes = [uint256(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (_getLifecycleStage(_dna) != LibUnicornDNA.LIFECYCLE_EGG) {
            mapping(uint256 => mapping(uint256 => uint256))
                storage globalIdsByBucket = LibGenes
                    .geneStorage()
                    .bodyPartGlobalIdFromLocalId[_getClass(_dna)];

            parts = [
                globalIdsByBucket[1][_getBodyPart(_dna)],
                globalIdsByBucket[2][_getFacePart(_dna)],
                globalIdsByBucket[3][_getHornPart(_dna)],
                globalIdsByBucket[4][_getHoovesPart(_dna)],
                globalIdsByBucket[5][_getManePart(_dna)],
                globalIdsByBucket[6][_getTailPart(_dna)]
            ];
            genes = [
                _getBodyMajorGene(_dna),
                _getBodyMidGene(_dna),
                _getBodyMinorGene(_dna),
                _getFaceMajorGene(_dna),
                _getFaceMidGene(_dna),
                _getFaceMinorGene(_dna),
                _getHornMajorGene(_dna),
                _getHornMidGene(_dna),
                _getHornMinorGene(_dna),
                _getHoovesMajorGene(_dna),
                _getHoovesMidGene(_dna),
                _getHoovesMinorGene(_dna),
                _getManeMajorGene(_dna),
                _getManeMidGene(_dna),
                _getManeMinorGene(_dna),
                _getTailMajorGene(_dna),
                _getTailMidGene(_dna),
                _getTailMinorGene(_dna)
            ];
        }
    }
}
