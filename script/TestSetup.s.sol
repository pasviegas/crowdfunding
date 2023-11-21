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
    function setUp() public returns (address, address, MockToken, Crowdfunding, CrowdfundingModule, address) {
        address supporter = makeAddr("supporter");
        address campaignOwner = makeAddr("campaignOwner");
        address platformOwner = makeAddr("platformOwner");

        MockToken token = new MockToken();
        TestAvatar safe = new TestAvatar();

        Crowdfunding crowdfunding = new Crowdfunding(token, 'xCamp', 'Campaign Share');
        crowdfunding.transferOwnership(address(safe));

        FeeModifier feeModifier = new FeeModifier(address(crowdfunding), address(safe), platformOwner, 1);
        safe.enableModule(address(feeModifier));

        GoalAchievedModifier goalModifier = new GoalAchievedModifier(address(crowdfunding), address(feeModifier), 100);
        feeModifier.enableModule(address(goalModifier));
        feeModifier.transferOwnership(address(safe));

        CrowdfundingModule module =
            new CrowdfundingModule(campaignOwner, address(safe), address(goalModifier), address(crowdfunding));

        goalModifier.enableModule(address(module));
        goalModifier.transferOwnership(address(safe));

        return (supporter, campaignOwner, token, crowdfunding, module, platformOwner);
    }

    function run() public {
        vm.broadcast();
    }
}
