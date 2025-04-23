pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SrcCoin is ERC20 {
    address immutable owner;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    function airdrop() external {
        _mint(msg.sender, 100);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
