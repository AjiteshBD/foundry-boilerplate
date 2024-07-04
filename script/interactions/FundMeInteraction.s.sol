//SPDX-Licenese-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

import {FundMe} from "../../src/FundMe.sol";

contract FundMeFundInteraction is Script {
    uint constant SEND_VALUE = 6e18;

    function fund(address _fundMe) public {
        vm.startBroadcast();
        FundMe(payable(_fundMe)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded with %s", SEND_VALUE);
    }

    function run() external {
        address latestContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fund(latestContract);
    }
}

contract FundMeWithdrawInteraction is Script {
    function withdraw(address _fundMe) public {
        vm.startBroadcast();
        FundMe(payable(_fundMe)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address latestContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdraw(latestContract);
    }
}
