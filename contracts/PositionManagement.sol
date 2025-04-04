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

contract PositionManagement{

    uint80 public msgNonce;
    message[] messageDB;
    mapping (address => uint256) balance;

    event messageEvent(uint256 msgNonce);

    function balanceOf(address depositor) external view returns(uint256){
        return balance[depositor];
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
        messageHandler(msg.value, msg.sender, funcEnum.deposit);
    }

    function withdraw(uint256 amount) external {
        require(balance[msg.sender] >= amount, "not enough funds to withdraw!");
        payable(msg.sender).transfer(amount);
        balance[msg.sender] -= amount;

        messageHandler(amount, msg.sender, funcEnum.withdraw);
    }

    function messageHandler(uint256 ethAmount, address depositor, funcEnum func) internal {
        emit messageEvent(msgNonce);
        messageDB.push(message(ethAmount, depositor, msgNonce, func));
        msgNonce = msgNonce + 1;
    }
}