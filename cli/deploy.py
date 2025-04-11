import argparse
import os
import sys
import subprocess
from utils.network import *


def deploy(net, contract_name, contract_sol):

    cmd = [
        "forge",
        "create",
        contract_sol,
        "--rpc-url=" + net.rpc_url,
        "--private-key=" + os.getenv("PRIVATE_KEY"),
        "--broadcast"
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)

    if res.returncode != 0:
        print(res)
        sys.exit(1)
    address = res.stdout.split("Deployed to: ")[1].split("\n")[0]
    print(contract_name, "address:", address)

    with open("addresses/" + net.dirname + contract_name, 'w') as file:
        file.write(address)



def main():

    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, help="Choose source chain(" + networks_str + ")")
    parser.add_argument('--dst', type=network_class, help="Choose destination chain(" + networks_str + ")")

    args = parser.parse_args()

    assert args.src is not None or args.dst is not None, "choose --src network for PositionManagement deployment and --dsc for Synthetic"

    if args.src is not None:
        deploy(args.src, "position_management", "contracts/PositionManagement.sol:PositionManagement")
    if args.dst is not None:
        deploy(args.dst, "synthetic_management", "contracts/SyntheticManagement.sol:SyntheticManagement")


if __name__ == "__main__":
    main()
