// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/SyntheticManagement.sol";


contract TestSyntheticManagement is Test {
    SyntheticManagement public syntheticManagement;
    address defaultSender = msg.sender;

    function setUp() public {
        syntheticManagement = new SyntheticManagement();
    }

    function testNonceAssertOnchain() public {
        vm.expectRevert("message nonce and messageBD.length are not equal");
        syntheticManagement.processMessageOnchain(0, address(0), 1, funcEnum.deposit, bytes(""));
    }

    function testNonceAssertZk() public {
        vm.expectRevert("message nonce and messageBD.length are not equal");
        syntheticManagement.processMessageZk(0, address(0), 1, funcEnum.deposit, bytes(""), bytes(""));
    }

}
