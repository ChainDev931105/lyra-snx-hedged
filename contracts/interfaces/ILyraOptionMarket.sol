// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ILyraOptionMarket {
    enum OptionType {
        LONG_CALL,
        LONG_PUT,
        SHORT_CALL_BASE,
        SHORT_CALL_QUOTE,
        SHORT_PUT_QUOTE
    }

    struct TradeInputParameters {
        // id of strike
        uint strikeId;
        // OptionToken ERC721 id for position (set to 0 for new positions)
        uint positionId;
        // number of sub-orders to break order into (reduces slippage)
        uint iterations;
        // type of option to trade
        OptionType optionType;
        // number of contracts to trade
        uint amount;
        // final amount of collateral to leave in OptionToken position
        uint setCollateralTo;
        // revert trade if totalCost is below this value
        uint minTotalCost;
        // revert trade if totalCost is above this value
        uint maxTotalCost;
        // referrer emitted in Trade event, no on-chain interaction
        address referrer;
    }

    struct Result {
        uint positionId;
        uint totalCost;
        uint totalFee;
    }

    function openPosition(TradeInputParameters memory params) external returns (Result memory result);

    function closePosition(TradeInputParameters memory params) external returns (Result memory result);

    function baseAsset() external returns (address);

    function quoteAsset() external returns (address);
}
