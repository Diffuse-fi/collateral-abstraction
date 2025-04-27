import argparse
import os
from cli.utils.contract_interaction import deploy, call_contract
from lib.sgx_verifier_deployer.script.utils.functions import parse_env_var
from lib.sgx_verifier_deployer.script.utils.network import network_class, networks_str
from lib.sgx_verifier_deployer.script.utils.wrapper import DCAP_ATTESTATION
from utils.addresses import read_address


def set_src_coin(net, coin_name, OCRate):
    deploy(net, coin_name, "contracts/SrcERC20TestCoin.sol:SrcCoin", ["ERC20_" + coin_name + "_test_tokens", coin_name])
    src_coin = read_address(net, coin_name)
    position_management = read_address(net, "position_management")
    call_contract(net, position_management, "addCurrency(address)", [src_coin])
    call_contract(net, position_management, "setOCRate(address, uint256)", [src_coin, OCRate])


def main():

    parser = argparse.ArgumentParser(description="Data feeder parameters")
    parser.add_argument('--src', type=network_class, help="Choose source chain(" + networks_str + ")")
    parser.add_argument('--dst', type=network_class, help="Choose destination chain(" + networks_str + ")")

    args = parser.parse_args()

    assert args.src is not None or args.dst is not None, "choose --src network for PositionManagement deployment and --dsc for Synthetic"

    if args.src is not None:
        deploy(args.src, "position_management", "contracts/PositionManagement.sol:PositionManagement")
        set_src_coin(args.src, "testETH", "1500")
        set_src_coin(args.src, "testBTC", "70000")
        set_src_coin(args.src, "testUSDC", "1")
        set_src_coin(args.src, "testUSDT", "1")
    if args.dst is not None:
        parse_env_var(args.dst, DCAP_ATTESTATION, root="lib/sgx_verifier_deployer/")
        deploy(args.dst, "synthetic_management", "contracts/SyntheticManagement.sol:SyntheticManagement")
        synthetic_management = read_address(args.dst, "synthetic_management")
        call_contract(args.dst, synthetic_management, "quoteVerifierUpdate(address newQuoteVerifierAddress)", [os.getenv("DCAP_ATTESTATION")])
        mrenclave = "0x11227b6a47a8543bef10fc0b459b58e0aecca0747b53f8ee6629fda787b17d0b"
        call_contract(args.dst, synthetic_management, "mrEnclaveUpdate(bytes32 mrEnclaveNew)", [mrenclave])


if __name__ == "__main__":
    main()
