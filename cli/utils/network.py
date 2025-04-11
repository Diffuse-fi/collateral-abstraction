from dataclasses import dataclass
import os
import sys

@dataclass(frozen=True)
class NetworkClass:
    name: str
    dirname: str
    rpc_url: str
    chain_id: str

alchemy_api_key = os.getenv('ALCHEMY_API_KEY')


ANVIL_1111 = NetworkClass(
    name="anvil_1111",
    dirname = "anvil_1111/",
    rpc_url="http://localhost:1111",
    chain_id="31337"
)

ANVIL_2222 = NetworkClass(
    name="anvil_2222",
    dirname = "anvil_2222/",
    rpc_url="http://localhost:2222",
    chain_id="31337"
)

ETH_SEPOLIA = NetworkClass(
    name="eth_sepolia",
    dirname = "eth_sepolia/",
    rpc_url="https://eth-sepolia.g.alchemy.com/v2/" + alchemy_api_key,
    chain_id="11155111"
)

ETH_HOLESKY = NetworkClass(
    name="eth_holesky",
    dirname = "eth_holesky/",
    rpc_url="https://eth-holesky.g.alchemy.com/v2/" + alchemy_api_key,
    chain_id="11155111"
)


networks = [
    ANVIL_1111,
    ANVIL_2222,
    ETH_SEPOLIA,
    ETH_HOLESKY,
]

networks_str = networks[0].name
for n in networks:
    if n==networks[0]:
        continue
    networks_str = networks_str + ", " + n.name


def network_class(name):
    for n in networks:
        if n.name == name:
            return n
    print("network with", name, "name is not found!")
    sys.exit(1)

