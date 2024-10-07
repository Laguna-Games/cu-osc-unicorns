// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract RepairRetryFlowsFacetFragment {
    function getEvolutionDataByVRFRequestIds(
        uint256[] calldata vrfRequestIds
    )
        external
        view
        returns (
            uint256[] memory blockDeadlines,
            uint256[] memory roundTripIds,
            uint256[] memory tokenIds,
            uint256[] memory upgradeBoosters,
            uint256[] memory rngs,
            uint256[] memory rngBlockNumbers
        )
    {}

    function getEvolutionVRFRequestIdsByRoundtripIds(
        uint256[] calldata roundTripIds
    ) external view returns (uint256[] memory vrfRequestIds) {}

    function getEvolutionRoundTripIdsByTokenIds(
        uint256[] calldata tokenIds
    ) external view returns (uint256[] memory roundTripIds) {}

    function setEvolutionTokenIdsByVRFRequestIds(
        uint256[] calldata vrfRequestIds,
        uint256[] calldata tokenIds
    ) external {}

    function getHatchingDataByVRFRequestIds(
        uint256[] calldata vrfRequestIds
    )
        external
        view
        returns (
            uint256[] memory blockDeadlines,
            uint256[] memory roundTripIds,
            uint256[] memory tokenIds,
            uint256[] memory inheritanceChances,
            uint256[] memory rngs,
            uint256[] memory rngBlockNumbers,
            uint256[] memory birthdays
        )
    {}

    function getHatchingVRFRequestIdsByRoundtripIds(
        uint256[] calldata roundTripIds
    ) external view returns (uint256[] memory vrfRequestIds) {}

    function getHatchingRoundTripIdsByTokenIds(
        uint256[] calldata tokenIds
    ) external view returns (uint256[] memory roundTripIds) {}

    function setHatchingTokenIdsByVRFRequestIds(
        uint256[] calldata vrfRequestIds,
        uint256[] calldata tokenIds
    ) external {}
}
