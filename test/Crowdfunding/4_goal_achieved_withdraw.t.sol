// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";

contract GoalAchievedWithdrawTest is Test {
    address public supporter;
    address public campaignOwner;

    MockToken public token;
    Crowdfunding public crowdfunding;

    function setUp() public {
        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding) = testSetup.setUp();
    }

    function test_should_not_be_able_to_withdraw_if_goal_achieved() public {
        // Given And I am the owner of a Crowdfunding Campaign Contract with 100 ERC20 deposited
        // ...

        // When I withdraw the funds from Crowdfunding Campaign Contract
        // ...

        // Then my balance for that token should be 100
        // ...
    }

    function test_should_not_be_able_to_withdraw_if_goal_not_achieved() public {
        // Given And I am the owner but the goal has not been achieved
        // ...

        // When I withdraw the funds from Crowdfunding Campaign Contract the transaction should be reverted
        // ...

        // And my balance for that token should be 0
        // ...
    }
}
