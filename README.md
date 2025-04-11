# collateral abstraction

## overview

contracts/PositionManagement.sol is deployed on the source chain.
contracts/SyntheticManagement.sol and contracts/SyntheticCoin.sol are deployed on the destination chain.

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
5. Interact with contracts
Deposit:
```bash
python3 cli/position_management.py --src local -d 1
```
Check balance:
```bash
python3 cli/position_management.py --src local -b
```
Withdraw:
```bash
python3 cli/position_management.py --src local -w 1
```
