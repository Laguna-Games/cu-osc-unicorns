// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract MetadataFacetFragment {
    event DNAUpdated(uint256 tokenId, uint256 dna);

    function getUnicornName(
        uint256 _tokenId
    ) external view returns (string memory) {}

    function getTargetDNAVersion() internal view returns (uint256) {}

    // function setTargetDNAVersion(uint256 _versionNumber) external {}

    function getDNA(uint256 _tokenId) external view returns (uint256) {}

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
    {}

    function getIdempotentState(
        uint256 _tokenId
    ) external view returns (uint256) {}

    function getUnicornParents(
        uint256 tokenId
    ) public view returns (uint256[2] memory parentIds) {}

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
    {}

    ///  Helper method for ERC-4906. This function emits the `MetadataUpdate` event.
    ///  @param _tokenId The ID of the token whose metadata has been updated.
    function emitMetadataUpdatedEvent(uint256 _tokenId) external {}

    ///  Helper method for ERC-4906. This function emits the `BatchMetadataUpdate` event.
    ///  @param _fromTokenId The ID of the token whose metadata has been updated.
    ///  @param _toTokenId The ID of the token whose metadata has being updated.
    function emitBatchMetadataUpdatedEvent(
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) external {}
}
