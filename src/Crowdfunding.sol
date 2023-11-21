// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdfunding is Ownable, ERC4626 {
    constructor(IERC20 _asset, string memory _shareName, string memory _shareSymbol)
        Ownable(_msgSender())
        ERC4626(_asset)
        ERC20(_shareName, _shareSymbol)
    { }

    function deposit(uint256 _amount) public {
        super.deposit(_amount, _msgSender());
    }

    function withdraw(address receiver, uint256 _amount) public onlyOwner {
        IERC20(super.asset()).approve(address(this), _amount);
        IERC20(super.asset()).transferFrom(address(this), receiver, _amount);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        virtual
        override
        onlyOwner
        returns (uint256)
    {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        override
        onlyOwner
        returns (uint256)
    {
        return super.redeem(shares, receiver, owner);
    }
}
