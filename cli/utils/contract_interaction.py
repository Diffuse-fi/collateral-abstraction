import os
import subprocess
import sys
from .foundry_cmd import cast_send_cmd, forge_create_cmd
from .addresses import write_address

def call_contract(net, contract_address, func_name, func_arg=None):

    cmd = cast_send_cmd(net, contract_address, func_name, func_arg)

    if func_name == "balanceOf(address)":
        cmd[1] = "call"

    print(func_name, func_arg, end=' ... ')
    res = run_command(cmd)
    print(res)



def deploy(net, contract_name, contract_sol):
    cmd = forge_create_cmd(net, contract_sol)

    stdout = run_command(cmd)
    address = stdout.split("Deployed to: ")[1].split("\n")[0]
    print(contract_name, "deployed to:", address)

    write_address(net, contract_name, address)



def run_command(cmd):
    res = subprocess.run(cmd, capture_output=True, text=True)

    if res.returncode != 0:
        print("FAILED!")
        print(res.stderr)
        sys.exit(1)

    print("SUCCESS")
    return(res.stdout)
