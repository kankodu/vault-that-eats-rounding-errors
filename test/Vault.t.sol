// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20, IERC20, Vault} from "../src/Vault.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MERC") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockVault is Vault {
    constructor(IERC20 asset_) Vault(asset_) {}

    function increaseTotalAssets(uint256 assets) public {
        _totalAssets += assets;
    }
}

contract VaultTest is Test {
    MockVault public vault;
    MockERC20 asset = new MockERC20();

    function setUp() public {
        asset.mint(address(this), 4);
        vault = new MockVault(asset);
    }

    function test_Deposit() public {
        asset.approve(address(vault), 2);
        vault.deposit(2, address(this));

        assertEq(vault.totalAssets(), 2);
        assertEq(vault.totalSupply(), 2);

        vault.increaseTotalAssets(1);

        assertEq(vault.totalAssets(), 3);
        assertEq(vault.totalSupply(), 2);

        asset.approve(address(vault), 1);
        vault.deposit(1, address(this));

        //In normal case it would have minted the user 0 shares but would have increased the total assets by 1
        //In this case the vault still mints the user 0 shares but doesn't increase the corrsponding total assets
        assertEq(vault.totalAssets(), 3);
        assertEq(vault.totalSupply(), 2);
    }
}
