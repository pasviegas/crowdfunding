// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.20;

import { Modifier } from "zodiac/core/Modifier.sol";
import { Enum } from "safe-contracts/common/Enum.sol";

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

contract GoalAchievedModifier is Modifier {
    error GoalNotAchieved();

    uint256 private goal;
    uint64 private startTimestamp;
    uint64 private durationSeconds;

    constructor(address _avatar, address _target, uint256 _goal, uint64 _start, uint64 _duration) {
        bytes memory initParams = abi.encode(_avatar, _target, _goal, _start, _duration);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override initializer {
        __Ownable_init(_msgSender());

        (address _avatar, address _target, uint256 _goal, uint64 _start, uint64 _duration) =
            abi.decode(initParams, (address, address, uint256, uint64, uint64));

        avatar = _avatar;
        target = _target;
        goal = _goal;
        startTimestamp = _start;
        durationSeconds = _duration;

        setupModules();
    }

    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        public
        override
        moduleOnly
        returns (bool success)
    {
        if (
            bytes4(data) == bytes4(keccak256("withdraw(address,uint256)"))
                && !canWithdraw(goal, uint64(block.timestamp))
        ) revert GoalNotAchieved();

        if (
            bytes4(data) == bytes4(keccak256("redeem(uint256,address,address)"))
                && !canRefund(goal, uint64(block.timestamp))
        ) revert GoalNotAchieved();

        return exec(to, value, data, operation);
    }

    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success, bytes memory returnData) {
        return execAndReturnData(to, value, data, operation);
    }

    function canWithdraw(uint256 _goal, uint64 _timestamp) internal view virtual returns (bool) {
        return IERC4626(avatar).totalAssets() >= _goal && _timestamp < end();
    }

    function canRefund(uint256 _goal, uint64 _timestamp) internal view virtual returns (bool) {
        return IERC4626(avatar).totalAssets() < _goal && _timestamp >= end();
    }

    function start() public view virtual returns (uint256) {
        return startTimestamp;
    }

    function duration() public view virtual returns (uint256) {
        return durationSeconds;
    }

    function end() public view virtual returns (uint256) {
        return start() + duration();
    }
}
