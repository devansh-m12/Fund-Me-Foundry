// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_contractOwner;
    uint256 private constant minimumDonationUSD = 5;
    address[] private s_donors;
    mapping(address => uint256) public s_donationAmountByDonor;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed){
        i_contractOwner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function donate() public payable {
        require(msg.value.convertPrice(s_priceFeed) >= minimumDonationUSD,"Donation amount is less than minimum required");
        s_donors.push(msg.sender);
        s_donationAmountByDonor[msg.sender]+=msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 donorIndex = 0; donorIndex < s_donors.length; donorIndex++){
            address s_donor = s_donors[donorIndex];
            s_donationAmountByDonor[s_donor] = 0;
        }

        s_donors = new address[](0);

        (bool transferSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(transferSuccess, "Transfer failed");
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 donerLength = s_donors.length;
        for(uint256 donorIndex = 0; donorIndex < donerLength ; donorIndex++){
            address s_donor = s_donors[donorIndex];
            s_donationAmountByDonor[s_donor] = 0;
        }

        s_donors = new address[](0);

        (bool transferSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(transferSuccess, "Transfer failed");
    }

    modifier onlyOwner(){
        require(msg.sender == i_contractOwner, "Only the contract owner can call this function");
        _;
    }

    /*
    * Getters
    */
   function getAddressToAmountDonated(address fundingAddress) external view returns(uint256){
       return s_donationAmountByDonor[fundingAddress];
    }

    function donors() public view returns(address[] memory){
        return s_donors;
    }
    function contractOwner() public view returns(address){
        return i_contractOwner;
    }

}
