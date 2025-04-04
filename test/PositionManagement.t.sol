// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/PositionManagement.sol";

contract TestPositionManagement is Test {
    PositionManagement public positionManagement;
    address defaultSender = msg.sender;

    function setUp() public {
        positionManagement = new PositionManagement();
    }

    function testNonce() public view {
        assertEq(positionManagement.msgNonce(), 0);
    }

    function testDeposit() public {
        vm.prank(defaultSender);
        positionManagement.deposit{value:1}();
        uint256 balance = positionManagement.balanceOf(defaultSender);
        assertEq(balance, 1);
        assertEq(positionManagement.msgNonce(), 1);
    }

    function testWithdraw() public {
        vm.prank(defaultSender);
        positionManagement.deposit{value:2}();
        vm.prank(defaultSender);
        positionManagement.withdraw(1);
        uint256 balance = positionManagement.balanceOf(defaultSender);
        assertEq(balance, 1);
        assertEq(positionManagement.msgNonce(), 2);
    }

    function testWithdrawFail() public {
        vm.prank(defaultSender);
        positionManagement.deposit{value:1}();
        vm.prank(defaultSender);
        vm.expectRevert("not enough funds to withdraw!");
        positionManagement.withdraw(2);
        assertEq(positionManagement.msgNonce(), 1);
    }

}
