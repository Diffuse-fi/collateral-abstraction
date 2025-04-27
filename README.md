# collateral abstraction

## overview
This repo works in pair with [collateral-watchtower](https://github.com/Diffuse-fi/collateral-watchtower) and [zktls-eth-proving](https://github.com/Diffuse-fi/zktls-eth-proving)

contracts/PositionManagement.sol is deployed on the source chain, user deposits ERC20 tokens in it.
contracts/SyntheticManagement.sol and contracts/SyntheticStablecoin.sol are deployed on the destination chain.

Users use PositionManagement to deposit and withdraw funds. This emits event, collateral-watchtower proves EVM storage and submits to SyntheticManagement.

## Tests
```bash
forge test
```

## CLI
Command line interface helps you interact with PositionManagement.
1. Export environment variables (example in .env.example)
```bash
source .env
```
and from lib/sgx_verifier_deployer
```bash
source lib/sgx_verifier_deployer/.env
```
2. Run two local nodes in different terminal windows:
```bash
anvil --port 1111
```
```bash
anvil --port 2222
```
3. Send funds to your `$PUBLIC_KEY` wallet on both local networks:

```bash
python3 cli/refresh_anvil.py
```

4. Deploy contracts
run
```bash
python3 cli/deploy.py --src local --dst local_2
```
this command will deploy PositionManagement and testETH, testBTC, testUSDC, testUSDT contracts on the src chain, SyntheticManagement and SyntheticStablecoin on the destination chain.

5. Interact with test tokens
Check balance
```bash
python3 cli/src_coin.py --src local -c testETH -b
```
Airdrop test tokens
```bash
python3 cli/src_coin.py --src local -c testETH -a
```

6. Interact with PositionManagement
Deposit:
```bash
python3 cli/position_management.py --src local -c testETH -d 1
```
Check deposit:
```bash
python3 cli/position_management.py --src local -c testETH -b
```
Check amount of minted stablecoins:
```bash
python3 cli/position_management.py --src local -c testETH -u
```
Withdraw:
```bash
python3 cli/position_management.py --src local -c testETH -w 1
```
