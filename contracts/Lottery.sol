// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract Lottery{

    address payable private adminAddress;
    bool private isLotteryActive;
    mapping(address => uint256) public participants;
    uint256 public participantsCount;
    AggregatorV3Interface public priceFeed;
    uint256 private minimumTicketPrice = 50 * 10 ** 8; //50 USD in 8 decimals 

    constructor() {
        adminAddress = payable(msg.sender);
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    function getAdminAddress() public view returns(address){
        return adminAddress;
    }

    function startLottery() public {
        require(msg.sender == adminAddress, "Only Admin can start the Lottery");
        require(isLotteryActive == false, "Lottery has already been started");
        isLotteryActive = true;
    }

    function endLottery() public {
        require(msg.sender == adminAddress, "Only Admin can start the Lottery");
        require(isLotteryActive == true, "Lottery is not active, you cannot end an inactive lottery");
        isLotteryActive = false;
    }

    function getLotteryStatus() public view returns(bool) {
        return isLotteryActive;
    }

    function buyLotteryTicket() public payable{
        require(isLotteryActive, "Lottery is not active");
        require(getEthToUsd(msg.value) >= minimumTicketPrice, "Not enough Money to buy the ticket");
        participantsCount ++;
        participants[msg.sender] += msg.value;
    }

    function getLotteryAmount(address participant) public view returns(uint256) {
        return participants[participant];
    }

    function getEthToUsd(uint256 ethAmount) public view returns(uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        //returns price with 8 decimal
        uint256 newPrice =  uint256(price);

        uint256 ethAmountInUsd = ethAmount * newPrice / 10 ** 18;

        return ethAmountInUsd;
    }
}