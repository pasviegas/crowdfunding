// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { CrowdfundingModule } from "../../src/CrowdfundingModule.sol";
import { GoalAchievedModifier } from "../../src/GoalAchievedModifier.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";

contract GoalAchievedWithdrawTest is Test {
    address public supporter;
    address public campaignOwner;

    MockToken public token;
    Crowdfunding public crowdfunding;
    CrowdfundingModule public module;

    function setUp() public {
        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding, module,) = testSetup.setUp();
    }

    function test_should_be_able_to_withdraw_if_goal_achieved() public {
        // Given And I am the owner of a Crowdfunding Campaign Contract with 100 ERC20 deposited
        token.mint(supporter, 100);
        vm.startPrank(supporter);
        token.approve(address(crowdfunding), 100);
        crowdfunding.deposit(100);
        vm.stopPrank();
        assertEq(token.balanceOf(address(crowdfunding)), 100);

        // When I withdraw the funds from Crowdfunding Campaign Contract
        vm.prank(campaignOwner);
        module.withdraw(campaignOwner, 100);

        // Then my balance for that token should be 99
        assertEq(token.balanceOf(campaignOwner), 99);
    }

    function test_should_not_be_able_to_withdraw_if_goal_not_achieved() public {
        token.mint(supporter, 90);

        // Given And I am the owner but the goal has not been achieved
        vm.startPrank(supporter);
        token.approve(address(crowdfunding), 90);
        crowdfunding.deposit(90);
        vm.stopPrank();

        assertEq(token.balanceOf(address(crowdfunding)), 90);

        // When I withdraw the funds from Crowdfunding Campaign Contract the transaction should be reverted
        vm.startPrank(campaignOwner);
        vm.expectRevert(GoalAchievedModifier.GoalNotAchieved.selector);
        module.withdraw(campaignOwner, 100);
        vm.stopPrank();

        // And my balance for that token should be 0
        assertEq(token.balanceOf(campaignOwner), 0);
    }
}
