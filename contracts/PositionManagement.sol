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
import {PositionNFT} from "./PositionNFT.sol";
import {SrcCoin} from "./SrcERC20TestCoin.sol";


interface ISymbol {
    function symbol() external view returns (string memory);
}

contract PositionManagement {

    address public immutable owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    mapping (address => PositionNFT) public positionNFTbyAddress;

    uint256 positionsNonce = 1;
    uint80 public msgNonce;
    message[] messageDB;

    event messageEvent(uint256 msgNonce);

    constructor() {
        owner = msg.sender;
    }

    function getCurrencyDeposit(address _currencyAddress) external view returns(uint256) {
        PositionNFT _positionNFT = positionNFTbyAddress[_currencyAddress];
        uint256 _positionId = _positionNFT.getPositionId(msg.sender);
        return _positionNFT.currencyDeposit(_positionId);
    }

    function getUsdDeposit(address _currencyAddress) external view returns(uint256) {
        PositionNFT _positionNFT = positionNFTbyAddress[_currencyAddress];
        uint256 _positionId = _positionNFT.getPositionId(msg.sender);
        return _positionNFT.usdDeposit(_positionId);
    }


    function addCurrency(address _currencyAddress) external onlyOwner {
        string memory currencySymbol = ISymbol(_currencyAddress).symbol();
        string memory _name = string.concat("Position management nft for ", currencySymbol);
        string memory _symbol = string.concat("pm", currencySymbol);
        PositionNFT positionNFT = new PositionNFT(_currencyAddress, _name, _symbol);
        positionNFTbyAddress[_currencyAddress] = positionNFT;
    }

    function setOCRate(address _currencyAddress, uint256 _OCRate) external onlyOwner {
        positionNFTbyAddress[_currencyAddress].setOCRate(_OCRate);
    }

    function newPosition(address currencyAddress) private returns(uint256) {
        uint256 positionId = positionsNonce;
        positionsNonce += 1;
        positionNFTbyAddress[currencyAddress].mint(msg.sender, positionId);
        return positionId;
    }

    function deposit(address _currencyAddress, uint256 _currencyAmount) external {
        SrcCoin currencyContract = SrcCoin(_currencyAddress);
        currencyContract.transferFrom(msg.sender, address(this), _currencyAmount);

        PositionNFT positionNFT = positionNFTbyAddress[_currencyAddress];
        // TODO what if someone tries to send positionNFT to address that already has another positionNFT? Need to enable ownership of several positionNFTs
        uint256 _positionId = positionNFT.getPositionId(msg.sender);
        if (_positionId == 0 ){
            _positionId = newPosition(_currencyAddress);
        }
        uint256 _usdAmount = positionNFT.deposit(_positionId, _currencyAmount);

        messageHandler(_usdAmount, _positionId, funcEnum.deposit);
    }


    function withdraw(address _currencyAddress, uint256 _currencyAmount) external {

        PositionNFT _positionNFT = positionNFTbyAddress[_currencyAddress];
        uint256 _positionId = _positionNFT.getPositionId(msg.sender);
        require(_positionNFT.currencyDeposit(_positionId) >= _currencyAmount, "not enough funds to withdraw!");

        uint256 _usdAmount = _positionNFT.withdraw(_positionId, _currencyAmount);

        SrcCoin _currencyContract = SrcCoin(_currencyAddress);
        _currencyContract.transfer(msg.sender, _currencyAmount);

        messageHandler(_usdAmount, _positionId, funcEnum.withdraw);
    }


    function messageHandler(uint256 usdAmount, uint256 depositor, funcEnum func) internal {
        emit messageEvent(msgNonce);
        messageDB.push(message(usdAmount, uint160(depositor), msgNonce, func));
        msgNonce = msgNonce + 1;
    }
}