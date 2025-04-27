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
    method_group.add_argument('-a', '--airdrop', action='store_true', help="Airdrop 100 test tokens")
    method_group.add_argument('-b', '--balance', action='store_true', help="Balance of the caller")
    args = parser.parse_args()

    src_coin = read_address(args.src, args.currency)

    match True:
        case args.airdrop:
            call_contract(args.src, src_coin, "airdrop()")
        case args.balance:
            call_contract(args.src, src_coin, "balanceOf(address)", [os.getenv("PUBLIC_KEY")])

if __name__ == "__main__":
    main()