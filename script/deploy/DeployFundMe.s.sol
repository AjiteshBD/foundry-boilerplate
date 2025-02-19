//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../utils/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig config = new HelperConfig();
        address ethUSDPriceFeed = config.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
