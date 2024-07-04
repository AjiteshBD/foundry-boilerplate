//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/deploy/DeployFundMe.s.sol";
import {console} from "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address T_USER = makeAddr("testuser");
    uint256 T_AMOUNT = 0.1 ether;
    uint256 INITIAL_BALANCE = 10 ether;
    uint256 GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(T_USER, INITIAL_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() external view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); // sending 0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(T_USER);
        fundMe.fund{value: T_AMOUNT}();
        uint amount = fundMe.getAddressToAmountFunded(T_USER);
        assertEq(amount, T_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(T_USER);
        fundMe.fund{value: T_AMOUNT}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, T_USER);
    }

    modifier funded() {
        vm.prank(T_USER);
        fundMe.fund{value: T_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(T_USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //Arrange
        uint startingBalanceOfOwner = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;
        //Act
        uint startgas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint endgas = gasleft();
        uint gasUsed = startgas - endgas * tx.gasprice;
        console.log(gasUsed);
        // Assert
        uint endingBalanceOfOwner = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingBalanceOfOwner,
            startingBalanceOfOwner + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: INITIAL_BALANCE}();
        }

        uint startingBalanceOfOwner = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint endingBalanceOfOwner = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingBalanceOfOwner,
            startingBalanceOfOwner + startingFundMeBalance
        );

        assertEq(endingFundMeBalance, 0);
    }
}
