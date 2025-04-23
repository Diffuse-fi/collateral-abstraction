// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/PositionManagement.sol";

contract TestPositionManagement is Test {
    PositionManagement public positionManagement;
    SrcCoin public testETH;
    SrcCoin public testBTC;
    address defaultSender = msg.sender;


    function setUp() public {
        testETH = new SrcCoin("testETH", "testETH");
        testBTC = new SrcCoin("testBTC", "testBTC");

        testETH.airdrop();
        testBTC.airdrop();

        vm.startPrank(defaultSender);
        testETH.airdrop();
        testBTC.airdrop();
        vm.stopPrank();

        positionManagement = new PositionManagement();
        positionManagement.addCurrency(address(testETH));
        positionManagement.addCurrency(address(testBTC));
    }


    function depositHelper(SrcCoin currencyContract, uint256 currencyAmount) public {
        currencyContract.approve(address(positionManagement), currencyAmount);
        positionManagement.deposit(address(currencyContract), currencyAmount);
    }

    function withdrawHelper(SrcCoin currencyContract, uint256 currencyAmount) public {
        positionManagement.withdraw(address(currencyContract), currencyAmount);
    }

    function depositChecker(SrcCoin currencyContract, uint256 balance, uint80 nonce) public view {
        assertEq(positionManagement.msgNonce(), nonce);
        assertEq(positionManagement.getCurrencyDeposit(address(currencyContract)), balance);
        uint256 OCRate = positionManagement.positionNFTbyAddress(address(currencyContract)).OCRate();
        assertEq(positionManagement.getUsdDeposit(address(currencyContract)), balance * OCRate);
    }


    function testNFTsymbol() public view {
        string memory symbol = positionManagement.positionNFTbyAddress(address(testETH)).symbol();
        assertEq(symbol, "pmtestETH");
    }

    function testNonce() public view {
        uint80 res = positionManagement.msgNonce();
        assertEq(res, 0);
    }


    function testDeposit() public {
        depositHelper(testETH, 1);
        depositChecker(testETH, 1, 1);
    }

    function testDeposit2() public {
        depositHelper(testETH, 1);
        depositHelper(testETH, 2);
        depositChecker(testETH, 3, 2);
    }

    function testDepositWithdraw() public {
        depositHelper(testETH, 2);
        depositHelper(testETH, 3);
        withdrawHelper(testETH, 1);
        depositChecker(testETH, 4, 3);
    }

    function testWithdrawFail() public {
        testETH.approve(address(positionManagement),1);
        vm.expectRevert("not enough funds to withdraw!");
        withdrawHelper(testETH, 1);
    }

    function test2currencies() public {
        depositHelper(testETH, 1);
        depositHelper(testBTC, 2);
        depositHelper(testETH, 3);
        depositHelper(testBTC, 4);
        depositChecker(testETH, 4, 4);
        depositChecker(testBTC, 6, 4);
    }

    function test2depositors() public {
        depositHelper(testETH, 1);
        depositHelper(testBTC, 2);
        vm.startPrank(defaultSender);
        depositHelper(testETH, 3);
        depositHelper(testBTC, 4);
        vm.stopPrank();

        depositChecker(testETH, 1, 4);
        depositChecker(testBTC, 2, 4);
        vm.startPrank(defaultSender);
        depositChecker(testETH, 3, 4);
        depositChecker(testBTC, 4, 4);
        vm.stopPrank();
    }

}
