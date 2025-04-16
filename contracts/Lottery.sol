// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    address public owner;
    uint256 public ticketPrice = 0.01 ether;
    uint256 public maxTickets = 100;
    uint256 public ticketCount = 0;
    address public winner;
    bool public lotteryEnded;

    mapping(uint256 => address) public ticketToOwner;
    mapping(address => bool) public hasTicket;

    event TicketPurchased(address indexed buyer, uint256 number);
    event WinnerDeclared(address indexed winner, uint256 number);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier lotteryActive() {
        require(!lotteryEnded, "Lottery has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function buyTicket(uint256 number) public payable lotteryActive {
        require(msg.value == ticketPrice, "Incorrect ETH sent");
        require(number < maxTickets, "Invalid ticket number");
        require(ticketToOwner[number] == address(0), "Ticket already bought");
        require(!hasTicket[msg.sender], "You already have a ticket");

        ticketToOwner[number] = msg.sender;
        hasTicket[msg.sender] = true;
        ticketCount++;

        emit TicketPurchased(msg.sender, number);

        if (ticketCount == maxTickets) {
            drawWinner();
        }
    }

    function drawWinner() public onlyOwner {
        require(!lotteryEnded, "Lottery already ended");
        require(ticketCount > 0, "No tickets sold");

        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % maxTickets;

        while (ticketToOwner[randomNumber] == address(0)) {
            randomNumber = (randomNumber + 1) % maxTickets;
        }

        winner = ticketToOwner[randomNumber];
        lotteryEnded = true;

        payable(winner).transfer(address(this).balance);

        emit WinnerDeclared(winner, randomNumber);
    }

    function getAvailableTickets() public view returns (uint256[] memory) {
        uint256[] memory available = new uint256[](maxTickets - ticketCount);
        uint256 index = 0;
        for (uint256 i = 0; i < maxTickets; i++) {
            if (ticketToOwner[i] == address(0)) {
                available[index++] = i;
            }
        }
        return available;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWinner() public view returns (address) {
        require(lotteryEnded, "Lottery not ended yet");
        return winner;
    }
}
