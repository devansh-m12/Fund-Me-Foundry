//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("USER");
    uint256 prankAmount = 0.1 ether;
    uint256 startBalance = 10 ether;

    FundMe fundMe;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, startBalance);
    }

    function testOwner() public {
        console.log("Owner is %s",fundMe.contractOwner());
        console.log("Sender is %s",msg.sender);
        assertEq(fundMe.contractOwner(),msg.sender);
    }

    function testDonateFails() public {
        vm.expectRevert("Donation amount is less than minimum required");
        fundMe.donate();
    }

    function testFundUpdateFundsDatastructure() public {
        vm.prank(USER);
        fundMe.donate{value: prankAmount}();
        uint256 amountDonated = fundMe.getAddressToAmountDonated(USER);
        assertEq(amountDonated,prankAmount);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.donate{value: prankAmount}();
        address[] memory funders = fundMe.donors();
        assertEq(funders.length,1);
        assertEq(funders[0],USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.donate{value: prankAmount}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public  funded {
        vm.prank(USER);
        vm.expectRevert("Only the contract owner can call this function");
        fundMe.withdraw();
    }

    function testWitdrawWithSingleFunder() public funded{
        uint256 initialOwnerBalance = fundMe.contractOwner().balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.contractOwner());
        fundMe.withdraw();

        uint256 finalOwnerBalance = fundMe.contractOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;

        assertEq(finalOwnerBalance,initialOwnerBalance+initialFundMeBalance);
        assertEq(finalFundMeBalance,0,"FundMe balance should be 0 wei");
    }

    function testWitdrawWithMultipleFunder() public funded {
        // Arange
        uint160  numberOfFunders = 5;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i),startBalance);
            fundMe.donate{value: prankAmount}();
        }
        uint256 initialOwnerBalance = fundMe.contractOwner().balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.contractOwner());
        fundMe.withdraw();
        vm.stopPrank();
        

        // Assert
        uint256 finalOwnerBalance = fundMe.contractOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;

        assertEq(finalOwnerBalance,initialOwnerBalance+initialFundMeBalance);
        assertEq(finalFundMeBalance,0,"FundMe balance should be 0 wei");
    }

    function testWitdrawWithMultipleFunderCheaper() public funded {
        // Arange
        uint160  numberOfFunders = 5;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i),startBalance);
            fundMe.donate{value: prankAmount}();
        }
        uint256 initialOwnerBalance = fundMe.contractOwner().balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.contractOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        

        // Assert
        uint256 finalOwnerBalance = fundMe.contractOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;

        assertEq(finalOwnerBalance,initialOwnerBalance+initialFundMeBalance);
        assertEq(finalFundMeBalance,0,"FundMe balance should be 0 wei");
    }
}

