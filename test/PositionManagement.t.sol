// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/PositionManagement.sol";

contract TestPositionManagement is Test {
    PositionManagement public positionManagement;
    SrcCoin public srcCoin;

    function setUp() public {
        positionManagement = new PositionManagement();
        srcCoin = new SrcCoin();
        positionManagement.setSrcCoin(address(srcCoin));
        srcCoin.airdrop();
    }

    function testBalance() public view {
        uint256 bal = srcCoin.balanceOf(address(this));
        assertEq(bal, 100);
    }

    function testNonce() public view {
        uint80 res = positionManagement.msgNonce();
        assertEq(res, 0);
    }

    function testDeposit() public {
        srcCoin.approve(address(positionManagement),1);
        positionManagement.deposit(1);
        uint256 balance = positionManagement.balanceOf(address(this));
        assertEq(balance, 1);
        assertEq(positionManagement.msgNonce(), 1);
    }

    function testWithdraw() public {
        srcCoin.approve(address(positionManagement),2);
        positionManagement.deposit(2);
        positionManagement.withdraw(1);
        uint256 balance = positionManagement.balanceOf(address(this));
        assertEq(balance, 1);
        assertEq(positionManagement.msgNonce(), 2);
    }

    function testWithdrawFail() public {
        srcCoin.approve(address(positionManagement),1);
        positionManagement.deposit(1);
        vm.expectRevert("not enough funds to withdraw!");
        positionManagement.withdraw(2);
        assertEq(positionManagement.msgNonce(), 1);
    }

}
