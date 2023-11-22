// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";

contract SimpleDepositTest is Test {
    address public supporter;
    address public campaignOwner;

    MockToken public token;
    Crowdfunding public crowdfunding;

    function setUp() public {
        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding,,,) = testSetup.setUp(0);
    }

    function test_supporter_should_be_able_to_deposit() public {
        // Given I have a balance of 100 of the same token
        token.mint(supporter, 100);
        assertEq(token.balanceOf(address(supporter)), 100);

        // When I approve and deposit 100 into the Crowdfunding Campaign Contract
        vm.startPrank(supporter);
        token.approve(address(crowdfunding), 100);
        crowdfunding.deposit(100);
        vm.stopPrank();

        // Then the balance of the Crowdfunding Campaign Contract for that token should be 100
        assertEq(token.balanceOf(address(crowdfunding)), 100);
    }
}
