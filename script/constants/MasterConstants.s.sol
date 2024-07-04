//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract MasterConstants is Script {
    //Address constants
    address public constant MAINNET_ETH_USD_PRICEFEED =
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant SEPOLIA_ETH_USD_PRICEFEED =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    //Number constants
    uint8 public constant PRICEFEED_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    //ChainID constants
    uint256 public constant MAINNET_CHAIN_ID = 1;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
}
