// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { CrowdfundingModule } from "../../src/CrowdfundingModule.sol";
import { GoalAchievedModifier } from "../../src/GoalAchievedModifier.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";
import { TestAvatar } from "zodiac/test/TestAvatar.sol";

contract RefundDepositTest is Test {
    address public supporter;
    address public campaignOwner;
    address public platformOwner;

    uint64 public cooldown = 180;

    MockToken public token;
    Crowdfunding public crowdfunding;
    CrowdfundingModule public module;
    TestAvatar public safe;

    function setUp() public {
        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding, module, platformOwner, safe) = testSetup.setUp(cooldown);
    }

    function test_should_refund_deposit_after_goal_not_achieved() public {
        token.mint(supporter, 90);

        // Given And I a supporter but the goal has not been achieved
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

        // And the owner y balance for that token should be 0
        assertEq(token.balanceOf(campaignOwner), 0);

        vm.warp(block.timestamp + cooldown + 1);

        // When I refund the funds from Crowdfunding Campaign Contract
        vm.startPrank(supporter);
        crowdfunding.approve(address(safe), 90);
        module.refund(supporter, 90);
        vm.stopPrank();

        // Then my balance for that token should be 90
        assertEq(token.balanceOf(supporter), 90);
    }
}
