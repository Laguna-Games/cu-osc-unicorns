// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibBin} from "../../lib/cu-osc-common/src/libraries/LibBin.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

/// @custom:storage-location erc7201:games.laguna.LibIdempotence
library LibIdempotence {
    uint256 internal constant MAX =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    //  GENESIS_HATCHING is in bit 0 = 0b1
    uint256 public constant IDMP_GENESIS_HATCHING_MASK = 0x1;
    //  HATCHING is in bit 1 = 0b10
    uint256 public constant IDMP_HATCHING_MASK = 0x2;
    //  EVOLVING is in bit 2 = 0b100
    uint256 public constant IDMP_EVOLVING_MASK = 0x4;
    //  PARENT IS BREEDING is in bit 3 = 0b1000
    uint256 public constant IDMP_PARENT_IS_BREEDING_MASK = 0x8;
    // NEW_EGG_WAITING_FOR_RNG is in bit 4 = 0b10000
    uint256 public constant IDMP_NEW_EGG_WAITING_FOR_RNG_MASK = 0x10;
    // NEW_EGG_RNG_RECEIVED_WAITING_FOR_TOKENURI is in bit 5 = 0b100000
    uint256
        public constant IDMP_NEW_EGG_RNG_RECEIVED_WAITING_FOR_TOKENURI_MASK =
        0x20;
    // HATCHING_STARTED is in bit 6 = 0b1000000
    uint256 public constant IDMP_HATCHING_STARTED_MASK = 0x40;
    // HATCHING_RANDOMNESS_FULFILLED is in bit 7 = 0b10000000
    uint256 public constant IDMP_HATCHING_RANDOMNESS_FULFILLED_MASK = 0x80;
    // EVOLUTION_STARTED is int bit 8 = 0b100000000
    uint256 public constant IDMP_EVOLUTION_STARTED_MASK = 0x100;
    // EVOLUTION_RANDOMNESS_FULFILLED is int bit 9 = 0b1000000000
    uint256 public constant IDMP_EVOLUTION_RANDOMNESS_FULFILLED_MASK = 0x200;

    bytes32 internal constant IDEMPOTENCE_STORAGE_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.LibIdempotence")) - 1)
        ) & ~bytes32(uint256(0xff));

    struct LibIdempotenceStorage {
        // The state of the NFT when it is round-tripping with the server
        mapping(uint256 => uint256) idempotence;
    }

    function idempotenceStorage()
        internal
        pure
        returns (LibIdempotenceStorage storage ids)
    {
        bytes32 position = IDEMPOTENCE_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ids.slot := position
        }
    }

    function enforceCleanState(uint256 _tokenId) internal view returns (bool) {
        require(
            !_getGenesisHatching(_tokenId) &&
                !_getHatching(_tokenId) &&
                !_getEvolving(_tokenId) &&
                !_getParentIsBreeding(_tokenId) &&
                !_getNewEggWaitingForRNG(_tokenId) &&
                !_getNewEggReceivedRNGWaitingForTokenURI(_tokenId),
            string.concat(
                "LibIdempotence: Token [",
                Strings.toString(_tokenId),
                "] is already in a workflow: ",
                Strings.toString(_getIdempotenceState(_tokenId))
            )
        );
        return true;
    }

    function _getIdempotenceState(
        uint256 _tokenId
    ) internal view returns (uint256) {
        return idempotenceStorage().idempotence[_tokenId];
    }

    function _setIdempotenceState(
        uint256 _tokenId,
        uint256 _state
    ) internal returns (uint256) {
        idempotenceStorage().idempotence[_tokenId] = _state;
        return _state;
    }

    function _clearState(uint256 _tokenId) internal {
        idempotenceStorage().idempotence[_tokenId] = 0;
    }

    function _setGenesisHatching(uint256 _tokenId, bool _val) internal {
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_GENESIS_HATCHING_MASK)
        );
    }

    function _getGenesisHatching(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_GENESIS_HATCHING_MASK);
    }

    function _setHatching(uint256 _tokenId, bool _val) internal {
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_HATCHING_MASK)
        );
    }

    function _getHatching(uint256 _tokenId) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_HATCHING_MASK);
    }

    function _setHatchingStarted(uint256 _tokenId, bool _val) internal {
        require(
            (_getHatchingRandomnessFulfilled(_tokenId) && _val) == false,
            "Cannot set both hatching flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_HATCHING_STARTED_MASK)
        );
    }

    function _getHatchingStarted(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_HATCHING_STARTED_MASK);
    }

    function _setHatchingRandomnessFulfilled(
        uint256 _tokenId,
        bool _val
    ) internal {
        require(
            (_getHatchingStarted(_tokenId) && _val) == false,
            "Cannot set both hatching flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_HATCHING_RANDOMNESS_FULFILLED_MASK)
        );
    }

    function _getHatchingRandomnessFulfilled(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return
            LibBin.extractBool(state, IDMP_HATCHING_RANDOMNESS_FULFILLED_MASK);
    }

    function _setEvolving(uint256 _tokenId, bool _val) internal {
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_EVOLVING_MASK)
        );
    }

    function _getEvolving(uint256 _tokenId) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_EVOLVING_MASK);
    }

    function _setParentIsBreeding(uint256 _tokenId, bool _val) internal {
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_PARENT_IS_BREEDING_MASK)
        );
    }

    function _getParentIsBreeding(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_PARENT_IS_BREEDING_MASK);
    }

    function _setNewEggWaitingForRNG(uint256 _tokenId, bool _val) internal {
        require(
            (_getNewEggReceivedRNGWaitingForTokenURI(_tokenId) && _val) ==
                false,
            "Cannot set both new_egg flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_NEW_EGG_WAITING_FOR_RNG_MASK)
        );
    }

    function _getNewEggWaitingForRNG(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_NEW_EGG_WAITING_FOR_RNG_MASK);
    }

    function _setNewEggReceivedRNGWaitingForTokenURI(
        uint256 _tokenId,
        bool _val
    ) internal {
        require(
            (_getNewEggWaitingForRNG(_tokenId) && _val) == false,
            "Cannot set both new_egg flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(
                state,
                _val,
                IDMP_NEW_EGG_RNG_RECEIVED_WAITING_FOR_TOKENURI_MASK
            )
        );
    }

    function _getNewEggReceivedRNGWaitingForTokenURI(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return
            LibBin.extractBool(
                state,
                IDMP_NEW_EGG_RNG_RECEIVED_WAITING_FOR_TOKENURI_MASK
            );
    }

    function _setEvolutionStarted(uint256 _tokenId, bool _val) internal {
        require(
            (_getEvolutionRandomnessFulfilled(_tokenId) && _val) == false,
            "Cannot set both evolution flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_EVOLUTION_STARTED_MASK)
        );
    }

    function _getEvolutionStarted(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return LibBin.extractBool(state, IDMP_EVOLUTION_STARTED_MASK);
    }

    function _setEvolutionRandomnessFulfilled(
        uint256 _tokenId,
        bool _val
    ) internal {
        require(
            (_getEvolutionStarted(_tokenId) && _val) == false,
            "Cannot set both evolution flags in true"
        );
        uint256 state = _getIdempotenceState(_tokenId);
        _setIdempotenceState(
            _tokenId,
            LibBin.splice(state, _val, IDMP_EVOLUTION_RANDOMNESS_FULFILLED_MASK)
        );
    }

    function _getEvolutionRandomnessFulfilled(
        uint256 _tokenId
    ) internal view returns (bool) {
        uint256 state = _getIdempotenceState(_tokenId);
        return
            LibBin.extractBool(state, IDMP_EVOLUTION_RANDOMNESS_FULFILLED_MASK);
    }
}
