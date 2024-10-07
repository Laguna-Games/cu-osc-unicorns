// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract JoustFacetFragment {
    /// @notice Get raw unicorn record for the tokenId
    /// @dev This ensures eloScore is 1000 when version is 0, and returns unicorn record
    /// @param tokenId - Unique id of the token
    /// @return unicornRecord - raw unicorn record for tokenId
    function getRawUnicornRecord(uint256 tokenId) public view returns (uint256) {}

    /// @notice Get raw unicorn record for the tokenId
    /// @dev This ensures eloScore is 1000 when version is 0, and returns unicorn record
    /// @param tokenIds - Unique id of the token
    /// @return _unicornRecord - raw unicorn record for tokenId
    function getBatchRawUnicornRecord(uint256[] memory tokenIds) public view returns (uint256[] memory) {}

    /// @notice Embeds version, wins, losses, tournamentWins and eloScore in unicorn record and returns new unicorn record
    /// @dev This function embeds version, joustWins, joustLosses, joustTournamentWins and joustEloScore to return new unicorn record
    /// @param tokenId - Unique id of token
    /// @param version - Data version
    /// @param joustWins - Joust matches won
    /// @param joustLosses - Joust matches lost
    /// @param joustTournamentWins - Joust tournament won
    /// @param joustEloScore - Joust elo score
    /// @return unicornRecord - Embedded unicorn record with updated version, wins, losses, tournamentWins and eloScore
    function getEmbeddedJoustRecord(
        uint256 tokenId,
        uint256 version,
        uint256 joustWins,
        uint256 joustLosses,
        uint256 joustTournamentWins,
        uint256 joustEloScore
    ) public view returns (uint256) {}

    /// @notice Embeds version, wins, losses, tournamentWins and eloScore in unicorn record and returns new unicorn record
    /// @dev This function embeds version, joustWins, joustLosses, joustTournamentWins and joustEloScore to return new unicorn record
    /// @param tokenIds - Unique id of tokens
    /// @param versions - Data version
    /// @param joustWins - Joust matches won
    /// @param joustLosses - Joust matches lost
    /// @param joustTournamentWins - Joust tournament won
    /// @param joustEloScores - Joust elo score
    /// @return unicornRecord - Embedded unicorn record with updated version, wins, losses, tournamentWins and eloScore
    function getBatchEmbeddedJoustRecord(
        uint256[] calldata tokenIds,
        uint256[] calldata versions,
        uint256[] calldata joustWins,
        uint256[] calldata joustLosses,
        uint256[] calldata joustTournamentWins,
        uint256[] calldata joustEloScores
    ) public view returns (uint256[] memory) {}

    /// @notice Embeds version in unicorn record and returns new unicorn record
    /// @dev The function splices the previous unicorn record and the new version
    /// @param unicornRecord - unicorn record of token
    /// @param version - version to be set in unicorn record
    /// @return unicornRecord - unicorn record with version
    function getEmbeddedVersion(uint256 unicornRecord, uint256 version) public view returns (uint256) {}

    /// @notice Embeds wins in unicorn record and returns new unicorn record
    /// @dev The function splices the previous unicorn record and the new wins
    /// @param unicornRecord - unicorn record of token
    /// @param wins - wins to be set in unicorn record
    /// @return unicornRecord - unicorn record with wins
    function getEmbeddedJoustWins(uint256 unicornRecord, uint256 wins) public pure returns (uint256) {}

    /// @notice Embeds losses in unicorn record and returns new unicorn record
    /// @dev The function splices the previous unicorn record and the new losses
    /// @param unicornRecord - unicorn record of token
    /// @param losses - losses to be set in unicorn record
    /// @return unicornRecord - unicorn record with losses
    function getEmbeddedJoustLosses(uint256 unicornRecord, uint256 losses) public pure returns (uint256) {}

    /// @notice Embeds tourneyWins in unicorn record and returns new unicorn record
    /// @dev The function splices the previous unicorn record and the new tourneyWins
    /// @param unicornRecord - unicorn record of token
    /// @param tourneyWins - tourneyWins to be set in unicorn record
    /// @return unicornRecord - unicorn record with tourneyWins
    function getEmbeddedJoustTournamentWins(uint256 unicornRecord, uint256 tourneyWins) public pure returns (uint256) {}

    /// @notice Embeds eloScore in unicorn record and returns new unicorn record
    /// @dev The function splices the previous unicorn record and the new eloScore
    /// @param unicornRecord - unicorn record of token
    /// @param eloScore - eloScore to be set in unicorn record
    /// @return unicornRecord - unicorn record with eloScore
    function getEmbeddedJoustEloScore(uint256 unicornRecord, uint256 eloScore) public pure returns (uint256) {}

    /// @notice Get Joust Record for the tokenId
    /// @dev The function ensures eloScore is 1000 when version is 0, and returns joustEloScore, joustWins, joustLosses, and joustTournamentWins
    /// @param tokenId - Unique id of the token
    /// @return version - version for tokenId
    /// @return matchesWon - joustWins for tokenId
    /// @return matchesLost - joustLosses for tokenId
    /// @return tournamentsWon - joustTournamentWins for tokenId
    /// @return eloScore - eloScore for tokenId
    function getJoustRecord(
        uint256 tokenId
    )
        public
        view
        returns (uint256 version, uint256 matchesWon, uint256 matchesLost, uint256 tournamentsWon, uint256 eloScore)
    {}

    /// @notice Get Batch Joust Record for the tokenIds
    /// @dev The function ensures eloScore is 1000 when version is 0, and returns joustEloScore, joustWins, joustLosses, and joustTournamentWins
    /// @param tokenIds - Unique id of the tokens
    /// @return versions - versions for tokenIds
    /// @return matchesWon - joustWins for tokenIds
    /// @return matchesLost - joustLosses for tokenIds
    /// @return tournamentsWon - joustTournamentWins for tokenIds
    /// @return eloScores - eloScores for tokenIds
    function getBatchJoustRecord(
        uint256[] calldata tokenIds
    )
        public
        view
        returns (
            uint256[] memory versions,
            uint256[] memory matchesWon,
            uint256[] memory matchesLost,
            uint256[] memory tournamentsWon,
            uint256[] memory eloScores
        )
    {}

    /// @notice Get joust elo scores for the tokenIds
    /// @dev The function sets the eloScore to 1000 when the version is 0, and otherwise, it returns the eloScore.
    /// @param tokenIds - Unique id of the tokens
    /// @return joustEloScores - joust elo scores for tokenIds
    function getJoustEloScores(uint256[] memory tokenIds) public view returns (uint256[] memory) {}
}
