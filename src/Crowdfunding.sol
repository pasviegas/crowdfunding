// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdfunding {

    IERC20 public asset;

    constructor(IERC20 _asset) {
        asset = _asset;
    }

    function deposit(uint256 _amount) public {
        asset.transferFrom(msg.sender, address(this), _amount);
    }
}
