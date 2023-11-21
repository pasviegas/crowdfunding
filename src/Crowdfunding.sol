// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdfunding is Ownable {
    IERC20 public asset;
    address public campaignOwner;

    constructor(address _campaignOwner, IERC20 _asset) Ownable(_campaignOwner) {
        asset = _asset;
        campaignOwner = _campaignOwner;
    }

    function deposit(uint256 _amount) public {
        asset.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw() public onlyOwner {
        uint256 amount = asset.balanceOf(address(this));

        asset.approve(address(this), amount);
        asset.transferFrom(address(this), msg.sender, amount);
    }
}
