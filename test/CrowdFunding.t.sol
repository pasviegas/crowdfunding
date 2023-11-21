// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Crowdfunding} from "../src/Crowdfunding.sol";
import {MockToken} from "../src/mocks/MockToken.sol";

contract CrowdfundingTest is Test {

    address public supporter;

    MockToken public token;
    Crowdfunding public crowdfunding;

    function setUp() public {
        supporter = makeAddr("supporter");

        token = new MockToken();
        crowdfunding = new Crowdfunding(token);
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
