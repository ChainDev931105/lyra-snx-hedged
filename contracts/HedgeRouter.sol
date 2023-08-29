// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILyraOptionMarket.sol";
import "./interfaces/ISNXFuturesMarket.sol";

import "hardhat/console.sol";

contract HedgeRouter is Ownable {
    using SafeERC20 for IERC20;

    ILyraOptionMarket public lyraMarket;
    ISNXFuturesMarket public snxMarket;
    IERC20 public USDC;
    IERC20 public WETH;
    IERC20 public SUSD;

    constructor() {}

    function init(address _lyraMarket, address _snxMarket, address _SUSD) external onlyOwner {
        lyraMarket = ILyraOptionMarket(_lyraMarket);
        snxMarket = ISNXFuturesMarket(_snxMarket);

        WETH = IERC20(lyraMarket.baseAsset());
        USDC = IERC20(lyraMarket.quoteAsset());
        SUSD = IERC20(_SUSD);

        USDC.safeApprove(address(lyraMarket), type(uint).max);
    }

    function buyHedgedCall(uint strikeId, uint amount) external onlyOwner {
        // uint orgBalance = USDC.balanceOf(address(this));
        ILyraOptionMarket.Result memory result = lyraMarket.openPosition(
            ILyraOptionMarket.TradeInputParameters({
                strikeId: strikeId,
                positionId: 0,
                iterations: 1,
                optionType: ILyraOptionMarket.OptionType.LONG_CALL,
                amount: amount,
                setCollateralTo: 0,
                minTotalCost: 0,
                maxTotalCost: type(uint).max,
                referrer: address(0)
            })
        );
        // uint newBalance = USDC.balanceOf(address(this));

        // console.log(result.positionId, result.totalCost, result.totalFee);
        // console.log(orgBalance, newBalance);

        // ISNXFuturesMarket.Position memory orgPosition = snxMarket.positions(address(this));
        snxMarket.modifyPosition(-int(amount));
        // ISNXFuturesMarket.Position memory newPosition = snxMarket.positions(address(this));

        // console.log(
        //     orgPosition.id,
        //     // orgPosition.lastFundingIndex,
        //     orgPosition.margin,
        //     orgPosition.lastPrice,
        //     uint128(orgPosition.size)
        // );
        // console.log(
        //     newPosition.id,
        //     // newPosition.lastFundingIndex,
        //     newPosition.margin,
        //     newPosition.lastPrice,
        //     newPosition.size > 0 ? uint128(newPosition.size) : uint128(-newPosition.size)
        // );
    }

    function addMargin(uint amount) external onlyOwner {
        require(amount <= uint256(type(int256).max), "Amount exceeds the limit");
        snxMarket.transferMargin(int256(amount));
        emit MarginAdded(amount);
    }

    function deposit(address token, uint amount) external {
        require(amount != 0, "Zero amount");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(token, amount);
    }

    function withdraw(address token, uint amount) external onlyOwner {
        require(amount != 0, "Zero amount");
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Withdrawn(token, amount);
    }

    event Deposited(address token, uint amount);
    event Withdrawn(address token, uint amount);
    event MarginAdded(uint amount);
}
