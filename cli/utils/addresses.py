

def read_address(net, contract):
    with open("addresses/" + net.dirname + contract, 'r') as file:
        address = file.read().strip()
    return address

def write_address(net, contract, address):
    with open("addresses/" + net.dirname + contract, 'w') as file:
        file.write(address)
