//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe){
        HelpConfig helpConfig = new HelpConfig();
        address ethActivePriceFeed = helpConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe =  new FundMe(ethActivePriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
