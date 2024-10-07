// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibAccessBadge} from "../../lib/cu-osc-common/src/libraries/LibAccessBadge.sol";

// TokenURIFacet is used to set token URIs on a Crypto Unicorns diamond contract.
contract TokenURIFacet {
    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external {
        LibCheck.enforceIsOwnerOrGameServer();
        require(
            LibERC721.exists(tokenId),
            string.concat(
                "TokenURI: Cannot set tokenURI for unminted token ",
                Strings.toString(tokenId)
            )
        );
        LibERC721.setTokenURI(tokenId, _tokenURI);
    }

    function batchSetTokenURI(
        uint256 startTokenId,
        string[] calldata _tokenURIs
    ) external {
        LibCheck.enforceIsOwnerOrGameServer();
        for (uint256 i = 0; i < _tokenURIs.length; i++) {
            LibERC721.setTokenURI(startTokenId + i, _tokenURIs[i]);
        }
    }

    function batchSetTokenURIs(
        uint256[] calldata _tokenIds,
        string[] calldata _tokenURIs
    ) external {
        LibCheck.enforceIsOwnerOrGameServer();
        require(
            _tokenIds.length == _tokenURIs.length,
            "TokenURI: Array must be equal length"
        );

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            LibERC721.setTokenURI(_tokenIds[i], _tokenURIs[i]);
        }
    }

    function batchMigrateTokenURIs(
        uint256[] calldata _tokenIds,
        string[] calldata _tokenURIs
    ) external {
        LibAccessBadge.requireBadge("migrator");
        require(
            _tokenIds.length == _tokenURIs.length,
            "TokenURI: Array must be equal length"
        );

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            LibERC721.setTokenURI(_tokenIds[i], _tokenURIs[i]);
        }
    }
}
