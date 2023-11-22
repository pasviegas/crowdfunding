// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.20;

import { Module } from "zodiac/core/Module.sol";
import { Enum } from "safe-contracts/common/Enum.sol";

import { Crowdfunding } from "./Crowdfunding.sol";

contract CrowdfundingModule is Module {
    address public crowdfunding;

    constructor(address _owner, address _avatar, address _target, address _crowdfunding) {
        bytes memory initializeParams = abi.encode(_owner, _avatar, _target, _crowdfunding);
        setUp(initializeParams);
    }

    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init(_msgSender());

        (address _owner, address _avatar, address _target, address _crowdfunding) =
            abi.decode(initializeParams, (address, address, address, address));

        crowdfunding = _crowdfunding;
        setAvatar(_avatar);
        setTarget(_target);
        transferOwnership(_owner);
    }

    function withdraw(address receiver, uint256 amount) external onlyOwner {
        exec(
            crowdfunding, 0, abi.encodeWithSignature("withdraw(address,uint256)", receiver, amount), Enum.Operation.Call
        );
    }

    function refund(address receiver, uint256 amount) external {
        exec(
            crowdfunding,
            0,
            abi.encodeWithSignature("redeem(uint256,address,address)", amount, receiver, receiver),
            Enum.Operation.Call
        );
    }
}
