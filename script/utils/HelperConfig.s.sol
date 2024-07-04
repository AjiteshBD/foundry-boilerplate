//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MasterConstants} from "../constants/MasterConstants.s.sol";
import {MockV3Aggregator} from "../../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    MasterConstants private m_constants;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        m_constants = new MasterConstants();
        if (block.chainid == m_constants.SEPOLIA_CHAIN_ID()) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == m_constants.MAINNET_CHAIN_ID()) {
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaETHConfig() public view returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: m_constants.SEPOLIA_ETH_USD_PRICEFEED()
        });
        return sepoliaConfig;
    }

    function getMainnetETHConfig() public view returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: m_constants.MAINNET_ETH_USD_PRICEFEED()
        });
        return ethConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //price feed address
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            m_constants.PRICEFEED_DECIMALS(),
            m_constants.INITIAL_PRICE()
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}
