// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ISNXFuturesMarket {
    struct Position {
        uint64 id;
        uint64 lastFundingIndex;
        uint128 margin;
        uint128 lastPrice;
        int128 size;
    }

    function modifyPosition(int sizeDelta) external;

    function closePosition() external;

    function transferMargin(int marginDelta) external;

    function positions(address) external view returns(Position memory position);
}
