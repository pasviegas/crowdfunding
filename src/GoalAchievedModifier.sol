// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.20;

import { Modifier } from "zodiac/core/Modifier.sol";
import { Enum } from "safe-contracts/common/Enum.sol";

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

contract GoalAchievedModifier is Modifier {
    error GoalNotAchieved();

    uint256 private goal;

    constructor(address _avatar, address _target, uint256 _goal) {
        bytes memory initParams = abi.encode(_avatar, _target, _goal);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override initializer {
        __Ownable_init(_msgSender());

        (address _avatar, address _target, uint256 _goal) = abi.decode(initParams, (address, address, uint256));

        setAvatar(_avatar);
        setTarget(_target);
        goal = _goal;

        setupModules();
    }

    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        public
        override
        moduleOnly
        returns (bool success)
    {
        if (!canExecute(goal)) revert GoalNotAchieved();

        return exec(to, value, data, operation);
    }

    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success, bytes memory returnData) {
        if (!canExecute(goal)) revert GoalNotAchieved();

        return execAndReturnData(to, value, data, operation);
    }

    function canExecute(uint256 _goal) internal view virtual returns (bool) {
        return IERC4626(avatar).totalAssets() >= _goal;
    }
}
