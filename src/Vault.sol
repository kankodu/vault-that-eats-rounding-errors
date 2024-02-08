// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault is ERC20 {
    IERC20 private immutable _asset;
    uint256 _totalAssets;

    constructor(IERC20 asset_) ERC20("Vault That Eats Rounding Errors", "VAULT") {
        _asset = asset_;
    }

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares, uint256 updatedAssets) {
        (updatedAssets, shares) = previewDeposit(assets);
        _deposit(msg.sender, receiver, updatedAssets, shares);
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _totalAssets += assets;
        _mint(receiver, shares);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256 updatedAssets, uint256 shares) {
        shares = _convertToShares(assets);
        updatedAssets = _convertToAssets(shares);
    }

    function _convertToShares(uint256 assets) internal view virtual returns (uint256) {
        return totalSupply() == 0 ? assets : assets * totalSupply() / totalAssets();
    }

    function _convertToAssets(uint256 shares) internal view virtual returns (uint256) {
        return totalSupply() == 0 ? shares : shares * totalAssets() / totalSupply();
    }

    function totalAssets() public view virtual returns (uint256) {
        return _totalAssets;
    }
}
