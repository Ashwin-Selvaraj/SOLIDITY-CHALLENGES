// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePaymentChannel {
    address public owner;
    address public recipient;
    mapping(address=>uint256) public depositedAmount;
    mapping(address=>uint256) public amountUtilized;
    uint256[] private paymentList;
    constructor(address recipientAddress) {
        owner=msg.sender;
        recipient = recipientAddress;
    }

    function deposit() public payable {
        require(msg.value>0,"Amount should be greater than 0");
        (bool success,) =address(this).call{value: msg.value}("");
        require(success,"Deposit Failed");
        depositedAmount[msg.sender]+=msg.value;
    }

    function listPayment(uint256 amount) public {
        require((amount + amountUtilized[msg.sender]) <=depositedAmount[msg.sender],"The amount is greater than the deposited amount");
        paymentList.push(amount);
        amountUtilized[msg.sender]+=amount;
    }

    function closeChannel() public {
        require(msg.sender == owner || msg.sender == recipient);
        (bool success1,) = owner.call{value: amountUtilized[recipient]}("");
        (bool success2,) = recipient.call{value: (depositedAmount[recipient] - amountUtilized[recipient])}("");
        require(success1==success2==true,"");
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getAllPayments() public view returns (uint256[] memory) {
        return paymentList;
    }

    fallback() external payable {
    revert("Fallback function called. Please use the deposit function to send Ether.");
    }
    receive() external payable {
    }
}