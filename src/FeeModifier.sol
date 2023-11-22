// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.20;

import { Modifier } from "zodiac/core/Modifier.sol";
import { Enum } from "safe-contracts/common/Enum.sol";
import { Math } from "@openzeppelin/contracts//utils/math/Math.sol";

contract FeeModifier is Modifier {
    using Math for uint256;

    address private platformOwner;
    uint256 private fee;

    constructor(address _avatar, address _target, address _platformOwner, uint256 _fee) {
        bytes memory initParams = abi.encode(_avatar, _target, _platformOwner, _fee);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override initializer {
        __Ownable_init(_msgSender());

        (address _avatar, address _target, address _platformOwner, uint256 _fee) =
            abi.decode(initParams, (address, address, address, uint256));

        avatar = _avatar;
        target = _target;
        fee = _fee;
        platformOwner = _platformOwner;

        setupModules();
    }

    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        public
        override
        moduleOnly
        returns (bool success)
    {
        if (bytes4(data) == bytes4(keccak256("withdraw(address,uint256)"))) {
            (address receiver, uint256 amount) = abi.decode(data[4:], (address, uint256));

            exec(
                to,
                0,
                abi.encodeWithSignature("withdraw(address,uint256)", platformOwner, amount.mulDiv(fee, 100)),
                Enum.Operation.Call
            );
            return exec(
                to,
                0,
                abi.encodeWithSignature("withdraw(address,uint256)", receiver, amount.mulDiv(100 - fee, 100)),
                Enum.Operation.Call
            );
        }

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
}
