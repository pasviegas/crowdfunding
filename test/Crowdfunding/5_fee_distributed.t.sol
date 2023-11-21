// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { CrowdfundingModule } from "../../src/CrowdfundingModule.sol";
import { GoalAchievedModifier } from "../../src/GoalAchievedModifier.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";

contract FeeDistributedTest is Test {
    address public supporter;
    address public campaignOwner;
    address public platformOwner;

    MockToken public token;
    Crowdfunding public crowdfunding;
    CrowdfundingModule public module;

    function setUp() public {
        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding, module,platformOwner) = testSetup.setUp();
    }

    function test_should_distribute_fee_to_platform_owner() public {
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

        // And the owner balance should be 1
        assertEq(token.balanceOf(platformOwner), 1);
    }
}
