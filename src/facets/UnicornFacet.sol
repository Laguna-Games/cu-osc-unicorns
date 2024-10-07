// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from '../libraries/LibUnicornDNA.sol';
import {LibUnicorn} from '../libraries/LibUnicorn.sol';

contract UnicornFacet {
    function batchBurnFrom(uint256[] memory tokenIds, address owner) external {
        LibUnicorn.batchBurnFrom(tokenIds, owner);
    }

    function batchSacrificeUnicorns(uint256[] memory tokenIds, address owner) external {
        LibUnicorn.batchSacrificeUnicorns(tokenIds, owner);
    }
}
