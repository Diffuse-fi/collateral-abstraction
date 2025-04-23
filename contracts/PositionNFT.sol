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
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract PositionNFT is ERC721 {

    address public immutable owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }


    address public immutable currencyAddress;
    uint256 public OCRate;


    constructor(address _currencyAddress, string memory _name, string memory _symbol) ERC721(_name, _symbol){
        currencyAddress = _currencyAddress;
        owner = msg.sender;
    }

    mapping(uint256 => uint256) public currencyDeposit;
    mapping(uint256 => uint256) public usdDeposit;
    mapping(address => uint256) public tokenIdByOwner;
    mapping(uint256 => address) public ownerByTokenId;

    function getPositionId(address _owner) public view returns(uint256) {
        return tokenIdByOwner[_owner];
    }

    function getOnwer(uint256 _tokenId) public view returns(address) {
        return ownerByTokenId[_tokenId];
    }

    function getUsdAmount(uint256 currencyAmount) public view returns(uint256) {
        return currencyAmount * OCRate;
    }

    function setOCRate(uint256 _OCRate) external onlyOwner {
        OCRate = _OCRate;
    }

    function mint(address _owner, uint256 _tokenId) external onlyOwner {
        _mint(_owner, _tokenId);
        tokenIdByOwner[_owner] = _tokenId;
        ownerByTokenId[_tokenId] = _owner;
    }

    function deposit(uint256 _positionId, uint256 _currencyAmount) external onlyOwner returns(uint256 _usdAmount) {
        currencyDeposit[_positionId] += _currencyAmount;
        usdDeposit[_positionId] += getUsdAmount(_currencyAmount);
    }

    function withdraw(uint256 _positionId, uint256 _currencyAmount) external onlyOwner returns(uint256 _usdAmount) {
        currencyDeposit[_positionId] -= _currencyAmount;
        usdDeposit[_positionId] -= getUsdAmount(_currencyAmount);
    }
}
