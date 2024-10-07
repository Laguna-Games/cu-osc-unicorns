// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ITwTUnicornInfo {
    struct TwTUnicornInfo {
        bool belongsToUser;
        bool isTransferrable;
        bool isGenesis;
        bool isAdult;
        uint8 amountOfMythicParts;
        uint8 class;
        uint256[] statsValues;
    }

    function twtGetUnicornInfoMultiple(
        uint256[3] memory tokenIds,
        uint256[] memory relevantStats,
        address user
    ) external view returns (TwTUnicornInfo[] memory);
}
