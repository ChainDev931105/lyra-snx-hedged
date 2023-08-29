import { assert, expect } from "chai";
import { AddressLike, BigNumberish, Signer } from "ethers";
import { ethers } from "hardhat";
import { time, impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

import { HedgeRouter, IERC20 } from "../typechain-types";

describe("HedgeRouter", function () {
  const LYRA_MARKET_ADDRESS = "0x59c671B1a1F261FB2192974B43ce1608aeFd328E";
  const SNX_MARKET_ADDRESS = "0xf86048DFf23cF130107dfB4e6386f574231a5C65";
  const SUSD_ADDRESS = "0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9";
  const OPTION_AMOUNT = ethers.parseEther("0.1"); // 0.1 ETH
  const COLLATERAL = 100 * 10 ** 6; // 100 USDC
  const MARGIN = ethers.parseEther("100"); // 100 SUSD

  let hedgeRouter: HedgeRouter;
  let user: Signer, otherUser: Signer;
  let WETH: IERC20, USDC: IERC20, SUSD: IERC20;

  before(async function () {
    [user, otherUser] = await ethers.getSigners();
  });

  it("Deployment & Initialize", async function () {
    hedgeRouter = await ethers.deployContract("HedgeRouter");
    await hedgeRouter.waitForDeployment();

    await (await hedgeRouter.init(LYRA_MARKET_ADDRESS, SNX_MARKET_ADDRESS, SUSD_ADDRESS)).wait();

    WETH = await ethers.getContractAt("IERC20", await hedgeRouter.WETH());
    USDC = await ethers.getContractAt("IERC20", await hedgeRouter.USDC());
    SUSD = await ethers.getContractAt("IERC20", SUSD_ADDRESS);
  });

  it("Deposit USDC", async function () {
    await airdropUSDC(await user.getAddress(), COLLATERAL);
    await USDC.approve(await hedgeRouter.getAddress(), COLLATERAL);

    const tx = await hedgeRouter.deposit(await USDC.getAddress(), COLLATERAL);
    await tx.wait();
  });

  it("Deposit SUSD & add margin to SNX", async function () {
    await airdropSUSD(await user.getAddress(), MARGIN);
    await SUSD.approve(await hedgeRouter.getAddress(), MARGIN);

    await hedgeRouter.deposit(await SUSD.getAddress(), MARGIN);

    const tx = await hedgeRouter.addMargin(MARGIN);
    await tx.wait();
  });

  it("Buy Hedge", async function () {
    const tx = await hedgeRouter.buyHedgedCall(260, OPTION_AMOUNT);
    await tx.wait();
  });

  // Mock functions for airdrop tokens
  const USDC_AIRDROP_ADDRESS = "0xEbe80f029b1c02862B9E8a70a7e5317C06F62Cae";
  const SUSD_AIRDROP_ADDRESS = "0xb729973d8c89c3225dAf9bC2b2f2E6805F1E641b";

  async function airdropUSDC(to: AddressLike, amount: BigNumberish) {
    await impersonateAccount(USDC_AIRDROP_ADDRESS);
    const signerAirdrop = await ethers.getSigner(USDC_AIRDROP_ADDRESS);
    await USDC.connect(signerAirdrop).transfer(to, amount);
  }

  async function airdropSUSD(to: AddressLike, amount: BigNumberish) {
    await impersonateAccount(SUSD_AIRDROP_ADDRESS);
    const signerAirdrop = await ethers.getSigner(SUSD_AIRDROP_ADDRESS);
    await SUSD.connect(signerAirdrop).transfer(to, amount);
  }
});
