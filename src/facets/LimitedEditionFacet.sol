// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibRNG} from "../../lib/cu-osc-common/src/libraries/LibRNG.sol";
import {LibUnicornNames} from "../libraries/LibUnicornNames.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibHatching} from "../libraries/LibHatching.sol";
import {LibStatCache} from "../libraries/LibStatCache.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";

contract LimitedEditionFacet {
    uint256 private constant SALT_1 = 1;
    uint256 private constant SALT_2 = 2;
    uint256 private constant SALT_3 = 3;
    uint256 private constant SALT_4 = 4;
    uint256 private constant SALT_5 = 5;
    uint256 private constant SALT_6 = 6;
    uint256 private constant SALT_7 = 7;
    uint256 private constant SALT_8 = 8;
    uint256 private constant SALT_9 = 9;
    uint256 private constant SALT_10 = 10;
    uint256 private constant SALT_11 = 11;
    uint256 private constant SALT_12 = 12;
    uint256 private constant SALT_13 = 13;
    uint256 private constant SALT_14 = 14;
    uint256 private constant SALT_15 = 15;
    uint256 private constant SALT_16 = 16;
    uint256 private constant SALT_17 = 17;
    uint256 private constant SALT_18 = 18;

    function mintLimitedEditionUnicorn(
        uint256 firstNameIndex,
        uint256 lastNameIndex,
        uint8 classId,
        string calldata tokenURI,
        uint256[6] memory bodyPartIds
    ) external {
        //Order: [body, face, horn, hooves, mane, tail]
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
        LibContractOwner.enforceIsContractOwner();
        require(classId <= 8, "LimitedEdition: Must be a valid classId");
        for (uint256 i = 0; i < 6; i++) {
            require(
                globalIdMatchesAValidPart(classId, i + 1, bodyPartIds[i]),
                getErrorMessageFor(i)
            );
        }
        require(
            bytes(LibUnicornNames._lookupFirstName(firstNameIndex)).length >
                0 &&
                bytes(LibUnicornNames._lookupLastName(lastNameIndex)).length >
                0,
            "LimitedEdition: First and last name indexes must be registered names."
        );

        require(
            !LibUnicornNames._firstNameIsAssignable(firstNameIndex) &&
                !LibUnicornNames._lastNameIsAssignable(lastNameIndex),
            "LimitedEdition: Both first and last name must be retired to use for limited edition"
        );

        uint256 tokenId = LibERC721.mintNextToken(msg.sender);

        uint256 dna = 0;
        dna = LibUnicornDNA._setClass(dna, classId);
        dna = LibUnicornDNA._setLimitedEdition(dna, true);
        dna = LibUnicornDNA._setLifecycleStage(
            dna,
            LibUnicornDNA.LIFECYCLE_ADULT
        );
        dna = LibUnicornDNA._setVersion(dna, LibUnicornDNA._targetDNAVersion());
        dna = LibUnicornDNA._setFirstNameIndex(dna, firstNameIndex);
        dna = LibUnicornDNA._setLastNameIndex(dna, lastNameIndex);

        dna = setBodyPartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[0]],
            gs
        );
        dna = setFacePartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[1]],
            gs
        );
        dna = setHornPartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[2]],
            gs
        );
        dna = setHoovesPartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[3]],
            gs
        );
        dna = setManePartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[4]],
            gs
        );
        dna = setTailPartAndGenes(
            dna,
            classId,
            gs.bodyPartLocalIdFromGlobalId[bodyPartIds[5]],
            gs
        );

        LibUnicornDNA._setDNA(tokenId, dna);
        LibStatCache.cacheNaturalStats(tokenId);
        us.hatchBirthday[tokenId] = block.timestamp;
        LibERC721.setTokenURI(tokenId, tokenURI);
    }

    function setBodyPartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setBodyPart(dna, localPartId);
        dna = LibUnicornDNA._setBodyMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_1
            )
        );
        dna = LibUnicornDNA._setBodyMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_2
            )
        );
        dna = LibUnicornDNA._setBodyMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_3
            )
        );
        return dna;
    }

    function setFacePartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setFacePart(dna, localPartId);
        dna = LibUnicornDNA._setFaceMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_4
            )
        );
        dna = LibUnicornDNA._setFaceMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_5
            )
        );
        dna = LibUnicornDNA._setFaceMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_6
            )
        );
        return dna;
    }

    function setHornPartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setHornPart(dna, localPartId);
        dna = LibUnicornDNA._setHornMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_7
            )
        );
        dna = LibUnicornDNA._setHornMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_8
            )
        );
        dna = LibUnicornDNA._setHornMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_9
            )
        );
        return dna;
    }

    function setHoovesPartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setHoovesPart(dna, localPartId);
        dna = LibUnicornDNA._setHoovesMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_10
            )
        );
        dna = LibUnicornDNA._setHoovesMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_11
            )
        );
        dna = LibUnicornDNA._setHoovesMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_12
            )
        );
        return dna;
    }

    function setManePartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setManePart(dna, localPartId);
        dna = LibUnicornDNA._setManeMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_13
            )
        );
        dna = LibUnicornDNA._setManeMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_14
            )
        );
        dna = LibUnicornDNA._setManeMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_15
            )
        );
        return dna;
    }

    function setTailPartAndGenes(
        uint256 dna,
        uint256 classId,
        uint256 localPartId,
        LibGenes.GeneStorage storage gs
    ) internal returns (uint256) {
        dna = LibUnicornDNA._setTailPart(dna, localPartId);
        dna = LibUnicornDNA._setTailMajorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_16
            )
        );
        dna = LibUnicornDNA._setTailMidGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_17
            )
        );
        dna = LibUnicornDNA._setTailMinorGene(
            dna,
            LibHatching.getRandomGeneId(
                gs,
                classId,
                LibRNG.getRuntimeRNG(),
                SALT_18
            )
        );
        return dna;
    }

    function globalIdMatchesAValidPart(
        uint256 classId,
        uint256 slotId,
        uint256 globalId
    ) internal view returns (bool isValid) {
        LibGenes.GeneStorage storage gs = LibGenes.geneStorage();

        uint256 localIdFromStorage = gs.bodyPartLocalIdFromGlobalId[globalId];
        if (localIdFromStorage == 0) return false;

        uint256 globalIdFromStorage = gs.bodyPartGlobalIdFromLocalId[classId][
            slotId
        ][localIdFromStorage];
        if (globalIdFromStorage != globalId) return false;

        return true;
    }

    function getErrorMessageFor(
        uint256 i
    ) internal pure returns (string memory) {
        string memory message;
        if (i == 0) {
            message = "LimtiedEdition: globalId index 0 does not match a valid body part for that classId";
        }
        if (i == 1) {
            message = "LimtiedEdition: globalId index 1 does not match a valid body part for that classId";
        }
        if (i == 2) {
            message = "LimtiedEdition: globalId index 2 does not match a valid body part for that classId";
        }
        if (i == 3) {
            message = "LimtiedEdition: globalId index 3 does not match a valid body part for that classId";
        }
        if (i == 4) {
            message = "LimtiedEdition: globalId index 4 does not match a valid body part for that classId";
        }
        if (i == 5) {
            message = "LimtiedEdition: globalId index 5 does not match a valid body part for that classId";
        }
        return message;
    }
}
