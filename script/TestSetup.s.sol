// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";

import { TestAvatar } from "zodiac/test/TestAvatar.sol";

import { Crowdfunding } from "../src/Crowdfunding.sol";
import { GoalAchievedModifier } from "../src/GoalAchievedModifier.sol";
import { FeeModifier } from "../src/FeeModifier.sol";
import { CrowdfundingModule } from "../src/CrowdfundingModule.sol";
import { MockToken } from "../src/mocks/MockToken.sol";

contract TestSetup is Script {
    address private supporter = makeAddr("supporter");
    address private campaignOwner = makeAddr("campaignOwner");
    address private platformOwner = makeAddr("platformOwner");

    MockToken private token = new MockToken();
    TestAvatar private safe = new TestAvatar();

    function setUp(uint64 cooldown)
        public
        returns (address, address, MockToken, Crowdfunding, CrowdfundingModule, address, TestAvatar)
    {
        Crowdfunding crowdfunding = new Crowdfunding(token, 'xCamp', 'Campaign Share');
        crowdfunding.transferOwnership(address(safe));

        FeeModifier feeModifier = new FeeModifier(address(crowdfunding), address(safe), platformOwner, 1);
        safe.enableModule(address(feeModifier));

        GoalAchievedModifier goalModifier = new GoalAchievedModifier(
            address(crowdfunding),
            address(feeModifier),
            100,
            uint64(block.timestamp),
            uint64(block.timestamp) + cooldown
        );

        feeModifier.enableModule(address(goalModifier));
        feeModifier.transferOwnership(address(safe));

        CrowdfundingModule module = new CrowdfundingModule(
            campaignOwner,
            address(safe),
            address(goalModifier),
            address(crowdfunding)
        );

        goalModifier.enableModule(address(module));
        goalModifier.transferOwnership(address(safe));

        return (supporter, campaignOwner, token, crowdfunding, module, platformOwner, safe);
    }

    function run() public {
        vm.broadcast();
    }
}
