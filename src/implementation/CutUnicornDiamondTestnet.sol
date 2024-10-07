// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CutUnicornDiamond} from "./CutUnicornDiamond.sol";
import {ERC721AdminFragment} from "../../lib/cu-osc-common-tokens/src/implementation/ERC721AdminFragment.sol";
// import {ERC721DebugFragment} from '../../lib/cu-osc-common-tokens/src/implementation/ERC721DebugFragment.sol';
import {NameLoaderFragment} from "./NameLoaderFragment.sol";
import {TuningFacetFragment} from "./TuningFacetFragment.sol";
import {LimitedEditionFacetFragment} from "./LimitedEditionFacetFragment.sol";
import {TokenURIFacetFragment} from "./TokenURIFacetFragment.sol";
import {StatCacheFacetFragmentTestnet} from "./StatCacheFacetFragment.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract CutUnicornDiamondTestnet is
    CutUnicornDiamond,
    ERC721AdminFragment,
    // ERC721DebugFragment,
    NameLoaderFragment,
    TuningFacetFragment,
    LimitedEditionFacetFragment,
    TokenURIFacetFragment,
    StatCacheFacetFragmentTestnet
{
    //  NOTE: We only use this one method from ERC721DebugFragment
    function debugSetTokenURI(
        uint256 tokenId,
        string calldata tokenURI
    ) external {}
}
