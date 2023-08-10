// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract DonateFundMe is Script {
    uint256 private constant SEND_VALUE = 0.01 ether;
    
    function donateFundMe(address mostRecentFundMe)  public payable {
        vm.startBroadcast();
        FundMe(payable(mostRecentFundMe)).donate{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Donated %s to %s",SEND_VALUE,mostRecentFundMe);
    }
        

    function run() external {
        address mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        donateFundMe(mostRecentFundMe);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}