# Lyra SNX Hedged

## Task
The last task is going to test your ability to integrate with multiple protocols, Lyra and SNX.  We are asking you to write a buyHedgedCall(uint strikeId, uint amount).  The function will buy call options and hedge the delta of the the options by shorting equal delta amount of ETH perpetual future on SNX.  So say for example if you buy 3 call option with call delta of 0.5 each, you will have to sell 3*0.5=1.5 of ETH future against it to make the overall portfolio delta neutral.

This should probably be done by forking Optimism in hardhat and you will need to find wallets with usdc (for trading options on Lyra) and susd (for trading perp on SNX) to impersonate.

Please be thorough and do this as you would if you would at a professional setting.  So everything should be tested and documented.

Bonus points if you can write a reHedge() function and fast forward the forked chain then run it.  Basically the delta of the option changes as underlier price moves so to keep the portfolio delta neutral, you will have to buy or sell more perpetual future to offset the change in delta of the options.  If you pick a block early 8/17 to fork, you will probably able to see the delta of the call option drop a lot after ETH crashed that day.

## Run
Firstly, copy `.env.example` and rename it to `.env`. Put your Infura api Key on there.
```
INFURA_API_KEY=<Your Infura Api Key>
```
Run this command.
``` bash
yarn test
```
