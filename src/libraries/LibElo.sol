// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {LibBin} from "../../lib/cu-osc-common/src/libraries/LibBin.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";

/// @custom:storage-location erc7201:games.laguna.LibElo
library LibElo {
    event UnicornRecordChanged(
        uint256 indexed tokenId,
        uint256 oldUnicornRecord,
        uint256 newUnicornRecord
    );
    event JoustOracleUpdated(
        address indexed oldOracle,
        address indexed newOracle
    );
    event TargetUnicornVersionUpdated(
        uint8 oldUnicornVersion,
        uint8 newUnicornVersion
    );

    //  version is in bits 0-7 = 0b11111111
    uint256 public constant DNA_VERSION_MASK = 0xFF;

    //  joustWins is in bits 8-27 = 0b1111111111111111111100000000
    uint256 public constant DNA_JOUSTWINS_MASK = 0xFFFFF00;

    //  joustLosses is in bits 28-47 = 0b111111111111111111110000000000000000000000000000
    uint256 public constant DNA_JOUSTLOSSES_MASK = 0xFFFFF0000000;

    //  joustTourneyWins is in bits 48-67 = 0b11111111111111111111000000000000000000000000000000000000000000000000
    uint256 public constant DNA_JOUSTTOURNEYWINS_MASK = 0xFFFFF000000000000;

    //  joustElo is in bits 68-81 = 0b1111111111111100000000000000000000000000000000000000000000000000000000000000000000
    uint256 public constant DNA_JOUSTELO_MASK = 0x3FFF00000000000000000;

    // Maximum value for 20 bits (1048576)
    uint256 public constant MAX_VALUE_20_BITS = 1048576;

    //  @dev Storage slot for Elo Storage
    bytes32 private constant ELO_STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256("games.laguna.LibElo")) - 1)) &
            ~bytes32(uint256(0xff));

    struct LibEloStorage {
        mapping(uint256 tokenId => uint256 record) unicornRecord;
        uint8 targetUnicornVersion;
    }

    function eloStorage()
        internal
        pure
        returns (LibEloStorage storage storageSlot)
    {
        bytes32 position = ELO_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            storageSlot.slot := position
        }
    }

    /// @notice Set raw unicorn record for the tokenId
    /// @dev The internal function validates joustWins, joustLosses, joustTournamentWins, and joustEloScore
    /// @param _tokenId - Unique id of the token
    /// @param _unicornRecord - Unicorn record data to be set for tokenId
    /// @custom:emits UnicornRecordChanged
    function _setRawUnicornRecord(
        uint256 _tokenId,
        uint256 _unicornRecord
    ) internal {
        require(
            LibERC721.exists(_tokenId),
            "LibElo: TokenID does not have owner"
        );

        require(_unicornRecord > 0, "LibElo: cannot set 0 as unicorn record");

        uint256 _oldUnicornRecord = eloStorage().unicornRecord[_tokenId];
        uint256 version = _getVersion(_unicornRecord);
        uint256 joustWins = _getJoustWins(_unicornRecord);
        uint256 joustLosses = _getJoustLosses(_unicornRecord);
        uint256 joustTournamentWins = _getJoustTournamentWins(_unicornRecord);
        uint256 joustEloScore = _getJoustEloScore(_unicornRecord);

        validateJoustData(
            version,
            joustWins,
            joustLosses,
            joustTournamentWins,
            joustEloScore
        );

        eloStorage().unicornRecord[_tokenId] = _unicornRecord;
        emit UnicornRecordChanged(_tokenId, _oldUnicornRecord, _unicornRecord);
    }

    /// @notice Set unicorn record for the token in jousting system
    /// @dev The external function can be called only by oracle or contract owner.
    /// @param _tokenId - Unique id of the token
    /// @param _joustWins - Joust matches won
    /// @param _joustLosses - Joust matches lost
    /// @param _joustTournamentWins - Joust tournament won
    /// @param _joustEloScore - Joust elo score
    /// @custom:emits UnicornRecordChanged
    function _setJoustRecord(
        uint256 _tokenId,
        uint256 _joustWins,
        uint256 _joustLosses,
        uint256 _joustTournamentWins,
        uint256 _joustEloScore
    ) internal {
        require(
            LibERC721.exists(_tokenId),
            "LibElo: TokenID does not have owner"
        );

        uint256 _oldUnicornRecord = eloStorage().unicornRecord[_tokenId];

        uint256 _newUnicornRecord = _getEmbeddedJoustRecord(
            _tokenId,
            _getTargetUnicornVersion(),
            _joustWins,
            _joustLosses,
            _joustTournamentWins,
            _joustEloScore
        );

        eloStorage().unicornRecord[_tokenId] = _newUnicornRecord;
        emit UnicornRecordChanged(
            _tokenId,
            _oldUnicornRecord,
            _newUnicornRecord
        );
    }

    /// @notice Set version in unicorn record and returns new unicorn record
    /// @dev The internal function splices the previous unicorn record and the new version
    /// @param unicornRecord - unicorn record of token
    /// @param version - version to be set in unicorn record
    /// @return newUnicornRecord - unicorn record with version
    function _setVersion(
        uint256 unicornRecord,
        uint256 version
    ) internal view returns (uint256) {
        enforceValidVersion(version);
        return LibBin.splice(unicornRecord, version, DNA_VERSION_MASK);
    }

    /// @notice Set wins in unicorn record and returns new unicorn record
    /// @dev The internal function splices the previous unicorn record and the new wins
    /// @param unicornRecord - unicorn record of token
    /// @param joustWins - wins to be set in unicorn record
    /// @return unicornRecord - unicorn record with wins
    function _setJoustWins(
        uint256 unicornRecord,
        uint256 joustWins
    ) internal pure returns (uint256) {
        enforceMax20Bits(joustWins, "Joust Wins");
        return LibBin.splice(unicornRecord, joustWins, DNA_JOUSTWINS_MASK);
    }

    /// @notice Set losses in unicorn record and returns new unicorn record
    /// @dev The internal function splices the previous unicorn record and the new losses
    /// @param unicornRecord - unicorn record of token
    /// @param joustLosses - losses to be set in unicorn record
    /// @return unicornRecord - unicorn record with losses
    function _setJoustLosses(
        uint256 unicornRecord,
        uint256 joustLosses
    ) internal pure returns (uint256) {
        enforceMax20Bits(joustLosses, "Joust Losses");
        return LibBin.splice(unicornRecord, joustLosses, DNA_JOUSTLOSSES_MASK);
    }

    /// @notice Set joustTournamentWins in unicorn record and returns new unicorn record
    /// @dev The internal function splices the previous unicorn record and the new joustTournamentWins
    /// @param unicornRecord - unicorn record of token
    /// @param joustTournamentWins - joustTournamentWins to be set in unicorn record
    /// @return unicornRecord - unicorn record with joustTournamentWins
    function _setJoustTournamentWins(
        uint256 unicornRecord,
        uint256 joustTournamentWins
    ) internal pure returns (uint256) {
        enforceMax20Bits(joustTournamentWins, "Joust Tournament Wins");
        return
            LibBin.splice(
                unicornRecord,
                joustTournamentWins,
                DNA_JOUSTTOURNEYWINS_MASK
            );
    }

    /// @notice Set eloScore in unicorn record and returns new unicorn record
    /// @dev The internal function splices the previous unicorn record and the new eloScore
    /// @param unicornRecord - unicorn record of token
    /// @param eloScore - eloScore to be set in unicorn record
    /// @return unicornRecord - unicorn record with eloScore
    function _setJoustEloScore(
        uint256 unicornRecord,
        uint256 eloScore
    ) internal pure returns (uint256) {
        validateJoustEloScore(eloScore);
        return LibBin.splice(unicornRecord, eloScore, DNA_JOUSTELO_MASK);
    }

    /// @notice Set target unicorn version for jousting system
    /// @dev The internal function validates the version number by checking against previous version and 8 bit value
    /// @param _versionNumber - New target unicorn version number
    /// @custom:emits TargetUnicornVersionUpdated
    function _setTargetUnicornVersion(uint8 _versionNumber) internal {
        uint8 _oldUnicornVersion = eloStorage().targetUnicornVersion;
        require(
            _versionNumber > _oldUnicornVersion,
            "LibElo: Unicorn version must be greater than previous value"
        );
        eloStorage().targetUnicornVersion = _versionNumber;
        emit TargetUnicornVersionUpdated(_oldUnicornVersion, _versionNumber);
    }

    /// @notice Embeds version, wins, losses, tournamentWins and eloScore in unicorn record and returns new unicorn record
    /// @dev This internal function validates version, joustWins, joustLosses, joustTournamentWins and joustEloScore
    /// @param version - Data version
    /// @param joustWins - Joust matches won
    /// @param joustLosses - Joust matches lost
    /// @param joustTournamentWins - Joust tournament won
    /// @param joustEloScore - Joust elo score
    /// @return unicornRecord - Embedded unicorn record with updated version, wins, losses, tournamentWins and eloScore
    function _getEmbeddedJoustRecord(
        uint256 tokenId,
        uint256 version,
        uint256 joustWins,
        uint256 joustLosses,
        uint256 joustTournamentWins,
        uint256 joustEloScore
    ) internal view returns (uint256) {
        uint256 unicornRecord = eloStorage().unicornRecord[tokenId];
        unicornRecord = _setVersion(unicornRecord, version);
        unicornRecord = _setJoustWins(unicornRecord, joustWins);
        unicornRecord = _setJoustLosses(unicornRecord, joustLosses);
        unicornRecord = _setJoustTournamentWins(
            unicornRecord,
            joustTournamentWins
        );
        unicornRecord = _setJoustEloScore(unicornRecord, joustEloScore);
        return unicornRecord;
    }

    /// @notice Get target unicorn version
    /// @dev The internal function returns the target unicorn version
    /// @return targetUnicornVersion - Target unicorn version for jousting system
    function _getTargetUnicornVersion() internal view returns (uint256) {
        return eloStorage().targetUnicornVersion;
    }

    /// @notice Get and return version from the unicorn record
    /// @dev The internal function extracts version from the unicorn record
    /// @param _unicornRecord - Elo data of token
    /// @return version - Version from unicorn record
    function _getVersion(
        uint256 _unicornRecord
    ) internal pure returns (uint256) {
        return LibBin.extract(_unicornRecord, DNA_VERSION_MASK);
    }

    /// @notice Get and return wins from the unicorn record
    /// @dev The internal function extracts wins from the unicorn record
    /// @param _unicornRecord - Elo data of token
    /// @return wins - Wins from unicorn record
    function _getJoustWins(
        uint256 _unicornRecord
    ) internal pure returns (uint256) {
        return LibBin.extract(_unicornRecord, DNA_JOUSTWINS_MASK);
    }

    /// @notice Get and return losses from the unicorn record
    /// @dev The internal function extracts losses from the unicorn record
    /// @param _unicornRecord - Elo data of token
    /// @return losses - Losses from unicorn record
    function _getJoustLosses(
        uint256 _unicornRecord
    ) internal pure returns (uint256) {
        return LibBin.extract(_unicornRecord, DNA_JOUSTLOSSES_MASK);
    }

    /// @notice Get and return tourneyWins from the unicorn record
    /// @dev The internal function extracts tourneyWins from the unicorn record
    /// @param _unicornRecord - Elo data of token
    /// @return tourneyWins - Tournament Wins from unicorn record
    function _getJoustTournamentWins(
        uint256 _unicornRecord
    ) internal pure returns (uint256) {
        return LibBin.extract(_unicornRecord, DNA_JOUSTTOURNEYWINS_MASK);
    }

    /// @notice Get and return eloScore from the unicorn record
    /// @dev The internal function extracts eloScore from the unicorn record
    /// @param _unicornRecord - Elo data of token
    /// @return eloScore - Elo Score from unicorn record
    function _getJoustEloScore(
        uint256 _unicornRecord
    ) internal pure returns (uint256) {
        return LibBin.extract(_unicornRecord, DNA_JOUSTELO_MASK);
    }

    /// @notice Get Joust Record for the tokenId
    /// @dev The internal function ensures eloScore is 1000 when version is 0, and returns joustEloScore, joustWins, joustLosses, and joustTournamentWins
    /// @param _tokenId - Unique id of the token
    /// @return version - version for tokenId
    /// @return matchesWon - joustWins for tokenId
    /// @return matchesLost - joustLosses for tokenId
    /// @return tournamentsWon - joustTournamentWins for tokenId
    /// @return eloScore - eloScore for tokenId
    function _getJoustRecord(
        uint256 _tokenId
    )
        internal
        view
        returns (
            uint256 version,
            uint256 matchesWon,
            uint256 matchesLost,
            uint256 tournamentsWon,
            uint256 eloScore
        )
    {
        uint256 _unicornRecord = _getRawUnicornRecord(_tokenId);
        uint256 _eloScore = _getJoustEloScore(_unicornRecord);
        if (_getVersion(_unicornRecord) == 0) {
            _eloScore = 1000;
        }

        return (
            _getVersion(_unicornRecord),
            _getJoustWins(_unicornRecord),
            _getJoustLosses(_unicornRecord),
            _getJoustTournamentWins(_unicornRecord),
            _eloScore
        );
    }

    /// @notice Get raw unicorn record for the tokenId
    /// @dev This function ensures eloScore is 1000 when version is 0, and returns unicorn record
    /// @param _tokenId - Unique id of the token
    /// @return unicornRecord - raw unicorn record for tokenId
    function _getRawUnicornRecord(
        uint256 _tokenId
    ) internal view returns (uint256) {
        if (_getVersion(eloStorage().unicornRecord[_tokenId]) != 0) {
            return eloStorage().unicornRecord[_tokenId];
        } else {
            uint256 eloScore = 1000;
            uint256 unicornRecord = eloStorage().unicornRecord[_tokenId];
            uint256 newUnicornRecord = _setVersion(
                _setJoustEloScore(unicornRecord, eloScore),
                _getTargetUnicornVersion()
            );
            return newUnicornRecord;
        }
    }

    /// @notice Enforce joust data is valid by checking each parameter
    function validateJoustData(
        uint256 version,
        uint256 joustWins,
        uint256 joustLosses,
        uint256 joustTournamentWins,
        uint256 joustEloScore
    ) internal view {
        enforceValidVersion(version);
        enforceMax20Bits(joustWins, "Joust Wins");
        enforceMax20Bits(joustLosses, "Joust Losses");
        enforceMax20Bits(joustTournamentWins, "Joust Tournament Wins");
        validateJoustEloScore(joustEloScore);
    }

    /// @notice Enforce joust data is less than max value of 20 bits
    function enforceMax20Bits(
        uint256 joustData,
        string memory message
    ) internal pure {
        string memory errorMessage = string(
            abi.encodePacked("LibElo: ", message, " should be below 1048576")
        );
        require(joustData < MAX_VALUE_20_BITS, errorMessage);
    }

    /// @notice Validate joust elo score is between 1 and 16000
    function validateJoustEloScore(uint256 joustEloScore) internal pure {
        require(
            joustEloScore <= 16000 && joustEloScore >= 1,
            "LibElo: Joust Elo Score should be within [1, 16000]"
        );
    }

    /// @notice Enforce caller is either oracle or contract owner
    function enforceIsOwnerOrOracle() internal view {
        require(
            msg.sender == LibResourceLocator.gameServerOracle() ||
                msg.sender == LibContractOwner.contractOwner(),
            "LibElo: Must be Owner or Oracle address"
        );
    }

    /// @notice Enforce unicorn version is target unicorn version
    function enforceValidVersion(uint256 version) internal view {
        require(
            version == _getTargetUnicornVersion(),
            "LibElo: Invalid unicorn version"
        );
    }
}
