import argparse
import os
import sys
import subprocess
from lib.sgx_verifier_deployer.script.utils.network import *


def refresh_anvil(net):

    anvil_default_private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

    cmd = [
        "cast",
        "send",
        os.getenv("PUBLIC_KEY"),
        "--value=100ether",
        "--rpc-url=" + net.rpc_url,
        "--private-key=" + anvil_default_private_key
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)

    if res.returncode != 0:
        print("FAILED!")
        print(res.stderr)

        sys.exit(1)
    print("SUCCESS")


refresh_anvil(LOCAL_NETWORK)
refresh_anvil(LOCAL_NETWORK_2)
