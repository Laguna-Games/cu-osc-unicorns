// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CutERC721Diamond} from "../../lib/cu-osc-common-tokens/src/implementation/CutERC721Diamond.sol";
import {AirlockFacetFragment} from "./AirlockFacetFragment.sol";
import {BatchAirlockFacetFragment} from "./BatchAirlockFacetFragment.sol";
import {BreedingBeginFacetFragment} from "./BreedingBeginFacetFragment.sol";
import {BreedingFinishFacetFragment} from "./BreedingFinishFacetFragment.sol";
import {BreedingRetryFacetFragment} from "./BreedingRetryFacetFragment.sol";
import {EvolutionFacetFragment} from "./EvolutionFacetFragment.sol";
import {GemsInventoryFacetFragment} from "./GemsInventoryFacetFragment.sol";
import {GeneticViewFacetFragment} from "./GeneticViewFacetFragment.sol";
import {HatchFacetFragment} from "./HatchFacetFragment.sol";
import {HatchingFacetFragment} from "./HatchingFacetFragment.sol";
import {JoustFacetFragment} from "./JoustFacetFragment.sol";
import {MetadataFacetFragment} from "./MetadataFacetFragment.sol";
import {NamesFacetFragment} from "./NamesFacetFragment.sol";
import {StatCacheFacetFragment} from "./StatCacheFacetFragment.sol";
import {StatsFacetFragment} from "./StatsFacetFragment.sol";
import {UnicornConstraintFacetFragment} from "./UnicornConstraintFacetFragment.sol";
import {UnicornFacetFragment} from "./UnicornFacetFragment.sol";
import {RepairRetryFlowsFacetFragment} from "./RepairRetryFlowsFacetFragment.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract CutUnicornDiamond is
    CutERC721Diamond,
    AirlockFacetFragment,
    BatchAirlockFacetFragment,
    BreedingBeginFacetFragment,
    BreedingFinishFacetFragment,
    BreedingRetryFacetFragment,
    EvolutionFacetFragment,
    GemsInventoryFacetFragment,
    GeneticViewFacetFragment,
    HatchFacetFragment,
    HatchingFacetFragment,
    JoustFacetFragment,
    MetadataFacetFragment,
    NamesFacetFragment,
    StatCacheFacetFragment,
    StatsFacetFragment,
    UnicornConstraintFacetFragment,
    UnicornFacetFragment,
    RepairRetryFlowsFacetFragment
{
    event GasReturnedToUser(
        uint256 amountReturned,
        uint256 txPrice,
        uint256 gasSpent,
        address indexed user,
        bool indexed success,
        string indexed transactionType
    );

    event GasReturnerMaxGasReturnedPerTransactionChanged(
        uint256 oldMaxGasReturnedPerTransaction,
        uint256 newMaxGasReturnedPerTransaction,
        address indexed admin
    );

    event GasReturnerInsufficientBalance(
        uint256 txPrice,
        uint256 gasSpent,
        address indexed user,
        string indexed transactionType
    );
}
