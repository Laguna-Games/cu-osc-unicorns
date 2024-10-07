// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibUnicornNames} from "../libraries/LibUnicornNames.sol";
import {LibIdempotence} from "../libraries/LibIdempotence.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibEvents} from "../libraries/LibEvents.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";
import {LibCheck} from "../libraries/LibCheck.sol";

contract MetadataFacet {
    function getUnicornName(
        uint256 _tokenId
    ) external view returns (string memory) {
        uint256 dna = LibUnicornDNA._getDNA(_tokenId);
        return LibUnicornNames._getFullNameFromDNA(dna);
    }

    function getTargetDNAVersion() internal view returns (uint256) {
        return LibUnicornDNA._targetDNAVersion();
    }

    function setTargetDNAVersion(uint256 _versionNumber) external {
        LibContractOwner.enforceIsContractOwner();

        require(
            _versionNumber > LibUnicornDNA._targetDNAVersion(),
            "DNAMigrationFacet: DNA version must be greater than previous value"
        );
        require(
            _versionNumber < 256,
            "DNAMigrationFacet: version cannot be greater than 8 bits"
        );
        LibUnicornDNA.dnaStorage().targetDNAVersion = _versionNumber;
    }

    function getDNA(uint256 _tokenId) external view returns (uint256) {
        return LibUnicornDNA._getDNA(_tokenId);
    }

    //  Returns paginated metadata of a player's tokens. Max page size is 12,
    //  smaller arrays are returned on the final page to fit the player's
    //  inventory. The `moreEntriesExist` flag is TRUE when additional pages
    //  are available past the current call.
    function getUnicornsByOwner(
        address _owner,
        uint32 _pageNumber
    )
        external
        view
        returns (
            uint256[] memory tokenIds,
            uint16[] memory classes,
            string[] memory names,
            bool[] memory gameLocked,
            bool moreEntriesExist
        )
    {
        uint256 balance = LibERC721.erc721Storage().balances[_owner];
        uint start = _pageNumber * 12;
        uint count = balance - start;
        if (count > 12) {
            count = 12;
            moreEntriesExist = true;
        }

        tokenIds = new uint256[](count);
        classes = new uint16[](count);
        names = new string[](count);
        gameLocked = new bool[](count);

        for (uint i = 0; i < count; ++i) {
            uint256 indx = start + i;
            uint256 tokenId = LibERC721.erc721Storage().ownedTokens[_owner][
                indx
            ];
            tokenIds[i] = tokenId;
            uint256 dna = LibUnicornDNA._getDNA(tokenId);
            classes[i] = LibUnicornDNA._getClass(dna);
            names[i] = LibUnicornNames._getFullNameFromDNA(dna);
            gameLocked[i] = LibUnicornDNA._getGameLocked(dna);
        }
    }

    function getIdempotentState(
        uint256 _tokenId
    ) external view returns (uint256) {
        return LibIdempotence._getIdempotenceState(_tokenId);
    }

    function getUnicornParents(
        uint256 tokenId
    ) public view returns (uint256[2] memory parentIds) {
        LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();
        parentIds[0] = us.unicornParents[tokenId][0];
        parentIds[1] = us.unicornParents[tokenId][1];
    }

    function getParentMetadata(
        uint256 tokenId
    )
        public
        view
        returns (
            uint256[2] memory parentTokenIds,
            uint256[2] memory parentClasses,
            uint256[2] memory parentBreedingPoints,
            string[2] memory parentNames,
            string[2] memory parentTokenURIs,
            uint256[6] memory firstParentBodyPartIds,
            uint256[18] memory firstParentGeneIds,
            uint256[6] memory secondParentBodyPartIds,
            uint256[18] memory secondParentGeneIds
        )
    {
        parentTokenIds = getUnicornParents(tokenId);
        uint256 firstParentDNA = LibUnicornDNA._getDNA(parentTokenIds[0]);
        uint256 secondParentDNA = LibUnicornDNA._getDNA(parentTokenIds[1]);
        parentClasses[0] = LibUnicornDNA._getClass(firstParentDNA);
        parentClasses[1] = LibUnicornDNA._getClass(secondParentDNA);
        parentBreedingPoints[0] = LibUnicornDNA._getBreedingPoints(
            firstParentDNA
        );
        parentBreedingPoints[1] = LibUnicornDNA._getBreedingPoints(
            secondParentDNA
        );
        parentNames[0] = LibUnicornNames._getFullName(parentTokenIds[0]);
        parentNames[1] = LibUnicornNames._getFullName(parentTokenIds[1]);
        parentTokenURIs[0] = LibERC721.erc721Storage().tokenURIs[
            parentTokenIds[0]
        ];
        parentTokenURIs[1] = LibERC721.erc721Storage().tokenURIs[
            parentTokenIds[1]
        ];
        (firstParentBodyPartIds, firstParentGeneIds) = LibUnicornDNA
            ._getGeneMapFromDNA(firstParentDNA);
        (secondParentBodyPartIds, secondParentGeneIds) = LibUnicornDNA
            ._getGeneMapFromDNA(secondParentDNA);
    }

    ///  Helper method for ERC-4906. This function emits the `MetadataUpdate` event.
    ///  @param _tokenId The ID of the token whose metadata has been updated.
    function emitMetadataUpdatedEvent(uint256 _tokenId) external {
        LibCheck.enforceIsOwnerOrGameServer();
        emit LibEvents.MetadataUpdate(_tokenId);
    }

    ///  Helper method for ERC-4906. This function emits the `BatchMetadataUpdate` event.
    ///  @param _fromTokenId The ID of the token whose metadata has been updated.
    ///  @param _toTokenId The ID of the token whose metadata has being updated.
    function emitBatchMetadataUpdatedEvent(
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) external {
        LibCheck.enforceIsOwnerOrGameServer();
        emit LibEvents.BatchMetadataUpdate(_fromTokenId, _toTokenId);
    }
}
