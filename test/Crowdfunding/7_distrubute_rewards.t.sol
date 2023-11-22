// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { Crowdfunding } from "../../src/Crowdfunding.sol";
import { SupporterNFT } from "../../src/SupporterNFT.sol";
import { MockToken } from "../../src/mocks/MockToken.sol";
import { TestSetup } from "../../script/TestSetup.s.sol";

contract DistributeRewardsTest is Test {
    address public supporter;
    address public supporter2 = makeAddr("supporter2");
    address public campaignOwner;

    MockToken public token;
    Crowdfunding public crowdfunding;
    SupporterNFT public nft;

    function setUp() public {
        nft = new SupporterNFT('https://nftimage.com');

        TestSetup testSetup = new TestSetup();

        (supporter, campaignOwner, token, crowdfunding,,,) = testSetup.setUp(0);
    }

    function test_supporter_should_check_crowdfunding_support_holders() public {
        token.mint(supporter, 100);
        assertEq(token.balanceOf(address(supporter)), 100);

        // When I approve and deposit 100 into the Crowdfunding Campaign Contract
        vm.startPrank(supporter);
        token.approve(address(crowdfunding), 100);
        crowdfunding.deposit(100);

        // And I transfer 100 shares to supporter2
        vm.expectEmit();
        emit IERC20.Transfer(supporter, supporter2, 100);
        crowdfunding.transfer(supporter2, 100);
        vm.stopPrank();

        // Then the supporter2 should have 100 shares and supporter 0
        assertEq(crowdfunding.balanceOf(address(supporter)), 0);
        assertEq(crowdfunding.balanceOf(address(supporter2)), 100);
    }

    function test_supporter_should_mint_nft_to_crowdfunding_support_holders() public {
        token.mint(supporter, 100);
        assertEq(token.balanceOf(address(supporter)), 100);

        // Given a supporter has 100 shares
        vm.startPrank(supporter);
        token.approve(address(crowdfunding), 100);
        crowdfunding.deposit(100);

        // And they transfer 100 shares to supporter2
        vm.expectEmit();
        emit IERC20.Transfer(supporter, supporter2, 100);
        crowdfunding.transfer(supporter2, 100);
        vm.stopPrank();

        // Calculations happen off-chain to check all the supporters

        // When the owner distributes a ERC721 as a reward to the supporters
        nft.safeMint(supporter2);

        // Then the supporter2 should receive the ERC721 reward
        assertEq(nft.balanceOf(address(supporter2)), 1);
    }
}
