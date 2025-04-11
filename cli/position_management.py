import argparse
import os
import sys
import subprocess
from utils.network import *


def manage_position(net, func_name, func_arg):

    with open("addresses/" + net.dirname + "position_management", 'r') as file:
        position_management_address = file.read().strip()

    cmd = [
        "cast",
        "send",
        position_management_address,
        func_name,
        func_arg,
        "--rpc-url=" + net.rpc_url,
        "--private-key=" + os.getenv("PRIVATE_KEY"),
    ]

    if func_name == "balanceOf(address)":
        cmd[1] = "call"

    print(func_name, func_arg, end=' ... ')

    res = subprocess.run(cmd, capture_output=True, text=True)

    if res.returncode != 0:
        print("FAILED!")
        print(res.stderr)

        sys.exit(1)
    print("SUCCESS")
    print(res.stdout)



def main():

    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, required=True, help="Choose source chain")

    parser.add_argument('-d', '--deposit', type=int, help="Tokens amount to deposit")
    parser.add_argument('-w', '--withdraw', type=int, help="Tokens amount to withdraw")

    parser.add_argument('-b', '--balance', action='store_true', help="Balance of the caller")


    args = parser.parse_args()

    if args.balance == True:
        manage_position(args.src, "balanceOf(address)", os.getenv("PUBLIC_KEY"))
        return


    assert (args.deposit is None) + (args.withdraw is None) == 1, "choose either --deposit or --withdraw!"

    if args.deposit is not None:
        manage_position(args.src, "deposit()", "--value=" + str(args.deposit))
    if args.withdraw is not None:
        manage_position(args.src, "withdraw(uint256)", str(args.withdraw))



if __name__ == "__main__":
    main()