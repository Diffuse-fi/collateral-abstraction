import os

def cast_send_cmd(net, contract_address, func_name, func_arg):
    cmd = [
        "cast",
        "send",
        contract_address,
        func_name
    ]
    if func_arg is not None:
        cmd.extend(func_arg)
    cmd.append("--rpc-url=" + net.rpc_url)
    cmd.append("--private-key=" + os.getenv("PRIVATE_KEY"))

    return cmd


def forge_create_cmd(net, contract_sol, constructor_args=None):
    cmd = [
        "forge",
        "create",
        contract_sol,
        "--rpc-url=" + net.rpc_url,
        "--private-key=" + os.getenv("PRIVATE_KEY"),
        "--broadcast"
    ]

    if constructor_args is not None:
        cmd.append("--constructor-args")
        cmd.extend(constructor_args)

    return cmd
