// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract GeneticViewFacetFragment {
    function getGeneTierById(uint256 _geneId) external view returns (uint256) {}

    function getGeneTierUpgradeById(uint256 _geneId) external view returns (uint256) {}

    function getGeneApplicationById(uint256 _geneId) external view returns (uint256) {}

    function getGeneBuckets(uint256 _classId) external view returns (uint256[] memory) {}

    function getGeneBucketSumWeights(uint256 _classId) external view returns (uint256) {}

    function getGeneWeightById(uint256 _geneId) external view returns (uint256) {}

    function getGeneBonusStatByGeneId(uint256 _geneId, uint256 _geneBonusSlot) external view returns (uint256) {}

    function getGeneBonusValueByGeneId(uint256 _geneId, uint256 _geneBonusSlot) external view returns (uint256) {}

    function getBodyPartLocalIdFromGlobalId(uint256 _globalPartId) external view returns (uint256) {}

    function getBodyPartIsMythic(uint256 _globalPartId) external view returns (bool) {}

    function getBodyPartInheritedGene(uint256 _globalPartId) external view returns (uint256) {}

    function getBodyPartBuckets(uint256 _classId, uint256 _partSlotId) external view returns (uint256[] memory) {}

    function getBodyPartGlobalIdFromLocalId(
        uint256 _classId,
        uint256 _partSlotId,
        uint256 _localPartId
    ) external view returns (uint256) {}

    function getBodyPartWeight(uint256 _globalPartId) external view returns (uint256) {}

    function getBaseStats(uint256 _classId, uint256 _statId) external view returns (uint256) {}

    //  Return the bodyparts and genes for a specific Unicorn token.
    //  @param tokenId - The NFT's id
    //  @return bodyPartIds - An ordered array of bodypart globalIds [body, face, horn, hooves, mane, tail]
    //  @return geneIds - An ordered array of gene ids [bodyMajor, bodyMid, bodyMinor, faceMajor, faceMid, faceMinor, hornMajor, hornMid, hornMinor, hoovesMajor, hoovesMid, hoovesMinor, maneMajor, maneMid, maneMinor, tailMajor, tailMid, tailMinor]
    function getUnicornGeneMap(
        uint256 tokenId
    ) external view returns (uint256[6] memory bodyPartIds, uint256[18] memory geneIds) {}

    //  Return the bodyparts and genes for a DNA sequence.
    //  @param dna - A Unicorn DNA sequence
    //  @return bodyPartIds - An ordered array of bodypart globalIds [body, face, horn, hooves, mane, tail]
    //  @return geneIds - An ordered array of geen ids [bodyMajor, bodyMid, bodyMinor, faceMajor, faceMid, faceMinor, hornMajor, hornMid, hornMinor, hoovesMajor, hoovesMid, hoovesMinor, maneMajor, maneMid, maneMinor, tailMajor, tailMid, tailMinor]
    function getGeneMapFromDNA(
        uint256 dna
    ) external view returns (uint256[6] memory bodyPartIds, uint256[18] memory geneIds) {}
}
