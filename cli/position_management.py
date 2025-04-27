import argparse
import os
from utils.contract_interaction import call_contract
from utils.addresses import read_address
from lib.sgx_verifier_deployer.script.utils.network import *


def main():
    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, required=True, help="Choose source chain")
    parser.add_argument('-c', '--currency', required=True, help="Choose currency")

    method_group = parser.add_mutually_exclusive_group()
    method_group.add_argument('-b', '--balance-currency', action='store_true', help="Request amount of deposited tokens")
    method_group.add_argument('-u', '--balance-usd', action='store_true', help="Request amount of minted stablecoins")
    method_group.add_argument('-d', '--deposit', type=int, help="Tokens amount to deposit")
    method_group.add_argument('-w', '--withdraw', type=int, help="Tokens amount to withdraw")
    args = parser.parse_args()


    position_management = read_address(args.src, "position_management")
    src_coin = read_address(args.src, args.currency)


    match True:
        case args.balance_currency:
            call_contract(args.src, position_management, "getCurrencyDeposit(address)", [src_coin])
        case args.balance_usd:
            call_contract(args.src, position_management, "getUsdDeposit(address)", [src_coin])
        case _ if args.deposit is not None:
            call_contract(args.src, src_coin, "approve(address, uint256)", [position_management, str(args.deposit)])
            call_contract(args.src, position_management, "deposit(address, uint256)", [src_coin, str(args.deposit)])
        case _ if args.withdraw is not None:
            call_contract(args.src, position_management, "withdraw(address, uint256)", [src_coin, str(args.withdraw)])


if __name__ == "__main__":
    main()