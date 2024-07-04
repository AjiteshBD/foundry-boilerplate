//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/deploy/DeployFundMe.s.sol";
import {console} from "forge-std/console.sol";
import {FundMeFundInteraction, FundMeWithdrawInteraction} from "../../script/interactions/FundMeInteraction.s.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    address T_USER = makeAddr("testuser");
    uint256 T_AMOUNT = 0.1 ether;
    uint256 INITIAL_BALANCE = 100 ether;
    uint256 GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(T_USER, INITIAL_BALANCE);
    }

    function testUserFundInteraction() external {
        vm.prank(T_USER);

        fundMe.fund{value: T_AMOUNT}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, T_USER);
        FundMeWithdrawInteraction interaction = new FundMeWithdrawInteraction();
        interaction.withdraw(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
