pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SrcCoin is ERC20 {
    address immutable owner;

    constructor() ERC20("SrcCoin", "TEST") {
        owner = msg.sender;
    }

    function airdrop() external {
        _mint(msg.sender, 100);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
