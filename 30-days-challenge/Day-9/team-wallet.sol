// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamWallet {
    address private owner;
    bool private executedOnce;
    address[] public winners;
    uint public totalCredits;
    mapping(address=>uint) public balanceOf;
    struct Transaction
    {
        address requester;
        uint amount;
        address[] approvers;
        address[] rejectors;
        string status;
    }
    Transaction[] public transactions;
    constructor()
    {
        owner=msg.sender;
    }

    //For setting up the wallet
    function setWallet(address[] memory members, uint256 credits1) public {
        require(msg.sender==owner,"only the deployer can access the contract");
        require(credits1>0,"Credits must be strictly greater than 0");
        require(members.length>0,"must contain atleast one member address");
        for(uint i=0;i<members.length;i++)
        {
            require(members[i]!=owner,"Deployer cannot be a member of the team");
        }
        require(executedOnce!=true,"This function can be executed only once");
        executedOnce=true;
        winners=members;
        totalCredits=credits1;
    }

    modifier winnersOnly()
    {
        bool is_a_winner;
        for(uint i=0;i<winners.length;i++)
        {
            if(msg.sender == winners[i])
            {
                is_a_winner=true;
            }
        }
        require(is_a_winner,"only winners can access this function");
        _;
    }

    //For spending amount from the wallet
    function spend(uint256 amount) public winnersOnly{
        require(amount>0,"The amount should be strictly greater than 0");
        if(amount>totalCredits) transactions.push(Transaction(msg.sender,amount,new address[](0), new address[](0),"failed"));
        else
        {
            if(winners.length==1) 
            {
                transactions.push(Transaction(msg.sender,amount,new address[](0), new address[](0),"debited"));
                totalCredits=totalCredits-amount;
                balanceOf[msg.sender]=amount;
            }

            else transactions.push(Transaction(msg.sender,amount,new address[](0), new address[](0),"pending"));
        }
        transactions[transactions.length-1].approvers.push(msg.sender);
        
    }

    modifier notApprovedOrRejected(uint n)
    {
        for(uint i=0;i<transactions[n].approvers.length;i++)
        {
            if(msg.sender==transactions[n].approvers[i])
            {
                revert();
            }
        }
        for(uint i=0;i<transactions[n].rejectors.length;i++)
        {
            if(msg.sender==transactions[n].rejectors[i])
            {
                revert();
            }
        }
        require(keccak256(abi.encodePacked(transactions[n].status))==keccak256(abi.encodePacked("pending")));
        _;
    }
    //For approving a transaction request
    function approve(uint256 n) public winnersOnly notApprovedOrRejected(n-1){
        transactions[n-1].approvers.push(msg.sender);
        if(transactions[n-1].approvers.length>(winners.length*7/10))
        {
            totalCredits=totalCredits-transactions[n-1].amount;
            balanceOf[msg.sender]=transactions[n-1].amount;
            transactions[n-1].status="debited";
        }
    }

    //For rejecting a transaction request
    function reject(uint256 n) public winnersOnly notApprovedOrRejected(n-1){
        transactions[n-1].rejectors.push(msg.sender);
        if(transactions[n-1].rejectors.length>(winners.length*3/10))
        {
            transactions[n-1].status="failed";
        }
    }

    //For checking remaing credits in the wallet
    function credits() public view winnersOnly returns (uint256) {
        return totalCredits;
    }

    //For checking nth transaction status
    function viewTransaction(uint256 n) public view winnersOnly returns (uint amount,string memory status){
        return  (transactions[n-1].amount,transactions[n-1].status);
       
    }
    //For checking the transaction stats for the wallet
    function transactionStats() public winnersOnly view returns (uint debitedCount,uint pendingCount,uint failedCount){
        for (uint i = 0; i < transactions.length; i++) {
            if (keccak256(bytes(transactions[i].status)) == keccak256(bytes("debited"))) {
                debitedCount++;
            } else if (keccak256(bytes(transactions[i].status)) == keccak256(bytes("pending"))) {
                pendingCount++;
            } else if (keccak256(bytes(transactions[i].status)) == keccak256(bytes("failed"))) {
                failedCount++;
            }
        }
        return (debitedCount, pendingCount,failedCount);
    }

}
