// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { Crowdfunding } from "../src/Crowdfunding.sol";
import { MockToken } from "../src/mocks/MockToken.sol";

contract TestSetup is Script {
    function setUp() public returns (address, address, MockToken, Crowdfunding) {
        address supporter = makeAddr("supporter");
        address campaignOwner = makeAddr("campaignOwner");

        MockToken token = new MockToken();
        Crowdfunding crowdfunding = new Crowdfunding(campaignOwner, token, 'xCamp', 'Campaign Share');

        return (supporter, campaignOwner, token, crowdfunding);
    }

    function run() public {
        vm.broadcast();
    }
}
