// Copyright 2025 Diffuse.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.20;

import {funcEnum, message} from "./Utils.sol";
import {SrcCoin} from "./SrcERC20TestCoin.sol";

contract PositionManagement{

    SrcCoin public srcCoin;
    bool srcCoinFlag = false;

    address public immutable owner;

    uint80 public msgNonce;
    message[] messageDB;
    mapping (address => uint256) balance;

    event messageEvent(uint256 msgNonce);

    constructor() {
        owner = msg.sender;
    }

    function setSrcCoin(address token) external {
        require(msg.sender == owner, "only owner can setSrcCoin");
        require(srcCoinFlag == false, "setSrcCoin can be called only once");
        srcCoin = SrcCoin(token);
        srcCoinFlag = true;
    }

    function balanceOf(address depositor) external view returns(uint256){
        return balance[depositor];
    }

    function deposit(uint256 amount) external {
        srcCoin.transferFrom(msg.sender, address(this), amount);
        balance[msg.sender] += amount;
        messageHandler(amount, msg.sender, funcEnum.deposit);
    }

    function withdraw(uint256 amount) external {
        require(balance[msg.sender] >= amount, "not enough funds to withdraw!");
        srcCoin.transfer(msg.sender, amount);
        balance[msg.sender] -= amount;
        messageHandler(amount, msg.sender, funcEnum.withdraw);
    }

    function messageHandler(uint256 usdAmount, address depositor, funcEnum func) internal {
        emit messageEvent(msgNonce);
        messageDB.push(message(usdAmount, depositor, msgNonce, func));
        msgNonce = msgNonce + 1;
    }
}