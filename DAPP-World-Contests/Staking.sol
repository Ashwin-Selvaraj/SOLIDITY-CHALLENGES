// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public token;
    address public owner;
    uint256 public totalStaked;
    uint256 constant SECONDS_PER_DAY = 86400; 
    uint256 constant SECONDS_PER_WEEK = 604800;
    uint256 constant SECONDS_PER_MONTH = 2629746;
    
    mapping(address=>uint256) public amountStaked;
    mapping(address=>uint256) public stakedTime;
    mapping(address => uint256) public interest;
    mapping(address => uint256) public balances;

    constructor(address _token) {
        owner=msg.sender;
        token=IERC20(_token);
    }

    // allows users to stake tokens
    function stake(uint256 amount) public {
        require(amount>0,"The amount should not be 0");
        require(token.balanceOf(msg.sender)>0,"Insufficient balance");
        if(amountStaked[msg.sender]!=0)
        {
            claimInterest();
            reedem(amountStaked[msg.sender]);
        }
        require(token.transfer(address(this), amount), "Transfer failed");
        stakedTime[msg.sender]=block.timestamp;
        amountStaked[msg.sender]+=amount;
        totalStaked+= amount;
    }

    // allows users to reedem staked tokens
    function reedem(uint256 amount) public {
        require(amountStaked[msg.sender]!=0,"The person has not staked any tokens");
        require(amountStaked[msg.sender]<amount,"Amount is more than staked tokens");
        token.transfer(msg.sender,amount);
        amountStaked[msg.sender]-=amount;
    }

    // transfers rewards to staker
    function claimInterest() public {
        require(amountStaked[msg.sender]>0,"The person has not staked any amount");
        interest[msg.sender]=getAccruedInterest(msg.sender);
        require(interest[msg.sender]>0,"No interest is due");
        token.transfer(msg.sender,interest[msg.sender]);
        stakedTime[msg.sender]=0;
    }

    // returns the accrued interest
    function getAccruedInterest(address user) public view returns (uint256 reward) {
        uint time = block.timestamp-stakedTime[msg.sender];
        if(time>=SECONDS_PER_DAY && time<SECONDS_PER_WEEK)
        {
            reward = amountStaked[user]/100;
        }
        else if(time>=SECONDS_PER_WEEK && time<SECONDS_PER_MONTH)
        {
            reward = amountStaked[user]/10;
        }
        else if(time>=SECONDS_PER_MONTH)
        {
            reward = amountStaked[user]/2;
        }
        else{
            reward=0;
        }
    }

    // allows owner to collect all the staked tokens
    function sweep() public {
        require(msg.sender == owner, "Caller is not the owner");
        require(token.transfer(owner, totalStaked), "Transfer failed");
    }
    
}