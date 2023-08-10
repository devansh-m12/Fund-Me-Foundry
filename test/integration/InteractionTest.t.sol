//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {DonateFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    address USER = makeAddr("USER");
    uint256 prankAmount = 1 ether;
    uint256 startBalance = 100 ether;

    FundMe fundMe;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, startBalance);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        DonateFundMe fundFundMe = new DonateFundMe();
        fundFundMe.donateFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}