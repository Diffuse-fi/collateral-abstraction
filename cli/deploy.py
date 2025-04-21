import argparse
from cli.utils.contract_interaction import deploy, call_contract
from lib.sgx_verifier_deployer.script.utils.network import network_class, networks_str
from utils.addresses import read_address


def set_src_coin(net):
    src_coin = read_address(net, "src_coin")
    position_management = read_address(net, "position_management")
    call_contract(net, position_management, "setSrcCoin(address)", [src_coin])


def main():

    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, help="Choose source chain(" + networks_str + ")")
    parser.add_argument('--dst', type=network_class, help="Choose destination chain(" + networks_str + ")")

    args = parser.parse_args()

    assert args.src is not None or args.dst is not None, "choose --src network for PositionManagement deployment and --dsc for Synthetic"

    if args.src is not None:
        deploy(args.src, "position_management", "contracts/PositionManagement.sol:PositionManagement")
        deploy(args.src, "src_coin", "contracts/SrcERC20TestCoin.sol:SrcCoin")
        set_src_coin(args.src)
    if args.dst is not None:
        deploy(args.dst, "synthetic_management", "contracts/SyntheticManagement.sol:SyntheticManagement")


if __name__ == "__main__":
    main()
