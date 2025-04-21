import argparse
import os
from utils.contract_interaction import call_contract
from utils.addresses import read_address
from lib.sgx_verifier_deployer.script.utils.network import *


def main():
    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, required=True, help="Choose source chain")

    method_group = parser.add_mutually_exclusive_group()
    method_group.add_argument('-a', '--airdrop', action='store_true', help="Airdrop 100 test tokens")
    method_group.add_argument('-b', '--balance', action='store_true', help="Balance of the caller")
    method_group.add_argument('-d', '--deposit', type=int, help="Tokens amount to deposit")
    method_group.add_argument('-w', '--withdraw', type=int, help="Tokens amount to withdraw")
    args = parser.parse_args()


    position_management = read_address(args.src, "position_management")
    src_coin = read_address(args.src, "src_coin")

    match True:
        case args.airdrop:
            call_contract(args.src, src_coin, "airdrop()")
        case args.balance:
            call_contract(args.src, position_management, "balanceOf(address)", [os.getenv("PUBLIC_KEY")])
        case _ if args.deposit is not None:
            call_contract(args.src, src_coin, "approve(address, uint256)", [position_management, str(args.deposit)])
            call_contract(args.src, position_management, "deposit(uint256)", [str(args.deposit)])
        case _ if args.withdraw is not None:
            call_contract(args.src, position_management, "withdraw(uint256)", [str(args.withdraw)])


if __name__ == "__main__":
    main()