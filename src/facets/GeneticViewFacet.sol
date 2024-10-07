// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from '../libraries/LibUnicornDNA.sol';
import {LibGenes} from '../libraries/LibGenes.sol';
import {LibUnicorn} from '../libraries/LibUnicorn.sol';

contract GeneticViewFacet {
    function getGeneTierById(uint256 _geneId) external view returns (uint256) {
        return LibGenes.geneStorage().geneTierById[_geneId];
    }

    function getGeneTierUpgradeById(uint256 _geneId) external view returns (uint256) {
        return LibGenes.geneStorage().geneTierUpgradeById[_geneId];
    }

    function getGeneApplicationById(uint256 _geneId) external view returns (uint256) {
        return LibGenes.geneStorage().geneApplicationById[_geneId];
    }

    function getGeneBuckets(uint256 _classId) external view returns (uint256[] memory) {
        return LibGenes.geneStorage().geneBuckets[_classId];
    }

    function getGeneBucketSumWeights(uint256 _classId) external view returns (uint256) {
        return LibGenes.geneStorage().geneBucketSumWeights[_classId];
    }

    function getGeneWeightById(uint256 _geneId) external view returns (uint256) {
        return LibGenes.geneStorage().geneWeightById[_geneId];
    }

    function getGeneBonusStatByGeneId(uint256 _geneId, uint256 _geneBonusSlot) external view returns (uint256) {
        return LibGenes.geneStorage().geneBonusStatByGeneId[_geneId][_geneBonusSlot];
    }

    function getGeneBonusValueByGeneId(uint256 _geneId, uint256 _geneBonusSlot) external view returns (uint256) {
        return LibGenes.geneStorage().geneBonusValueByGeneId[_geneId][_geneBonusSlot];
    }

    function getBodyPartLocalIdFromGlobalId(uint256 _globalPartId) external view returns (uint256) {
        return LibGenes.geneStorage().bodyPartLocalIdFromGlobalId[_globalPartId];
    }

    function getBodyPartIsMythic(uint256 _globalPartId) external view returns (bool) {
        return LibGenes.geneStorage().bodyPartIsMythic[_globalPartId];
    }

    function getBodyPartInheritedGene(uint256 _globalPartId) external view returns (uint256) {
        return LibGenes.geneStorage().bodyPartInheritedGene[_globalPartId];
    }

    function getBodyPartBuckets(uint256 _classId, uint256 _partSlotId) external view returns (uint256[] memory) {
        return LibGenes.geneStorage().bodyPartBuckets[_classId][_partSlotId];
    }

    function getBodyPartGlobalIdFromLocalId(
        uint256 _classId,
        uint256 _partSlotId,
        uint256 _localPartId
    ) external view returns (uint256) {
        return LibGenes.geneStorage().bodyPartGlobalIdFromLocalId[_classId][_partSlotId][_localPartId];
    }

    function getBodyPartWeight(uint256 _globalPartId) external view returns (uint256) {
        return LibGenes.geneStorage().bodyPartWeight[_globalPartId];
    }

    function getBaseStats(uint256 _classId, uint256 _statId) external view returns (uint256) {
        return LibUnicorn.unicornStorage().baseStats[_classId][_statId];
    }

    //  Return the bodyparts and genes for a specific Unicorn token.
    //  @param tokenId - The NFT's id
    //  @return bodyPartIds - An ordered array of bodypart globalIds [body, face, horn, hooves, mane, tail]
    //  @return geneIds - An ordered array of gene ids [bodyMajor, bodyMid, bodyMinor, faceMajor, faceMid, faceMinor, hornMajor, hornMid, hornMinor, hoovesMajor, hoovesMid, hoovesMinor, maneMajor, maneMid, maneMinor, tailMajor, tailMid, tailMinor]
    function getUnicornGeneMap(
        uint256 tokenId
    ) external view returns (uint256[6] memory bodyPartIds, uint256[18] memory geneIds) {
        return LibUnicornDNA._getGeneMapFromDNA(LibUnicornDNA._getDNA(tokenId));
    }

    //  Return the bodyparts and genes for a DNA sequence.
    //  @param dna - A Unicorn DNA sequence
    //  @return bodyPartIds - An ordered array of bodypart globalIds [body, face, horn, hooves, mane, tail]
    //  @return geneIds - An ordered array of geen ids [bodyMajor, bodyMid, bodyMinor, faceMajor, faceMid, faceMinor, hornMajor, hornMid, hornMinor, hoovesMajor, hoovesMid, hoovesMinor, maneMajor, maneMid, maneMinor, tailMajor, tailMid, tailMinor]
    function getGeneMapFromDNA(
        uint256 dna
    ) external view returns (uint256[6] memory bodyPartIds, uint256[18] memory geneIds) {
        return LibUnicornDNA._getGeneMapFromDNA(dna);
    }
}
