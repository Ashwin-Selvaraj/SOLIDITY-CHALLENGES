// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Wallet {
    address public owner;
    mapping (address=>uint) public addressToAmount;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    function deposit() external payable {
        // Allow deposits
        addressToAmount[msg.sender]+=msg.value;
    }
    
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }
    
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable 
    {
        // Handle incoming Ether
    }
}