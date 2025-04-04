pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SyntheticCoin is ERC20 {
    address immutable owner;

    constructor() ERC20("SyntheticCoin", "TEST") {
        owner = msg.sender;
    }

    function mint(uint256 value) external {
        require(msg.sender == owner, "only owner can mint tokens");
        _mint(owner, value);
    }

    function burn(uint256 value) external {
        require(msg.sender == owner, "only owner can burn tokens");
        _burn(owner, value);
    }
}
