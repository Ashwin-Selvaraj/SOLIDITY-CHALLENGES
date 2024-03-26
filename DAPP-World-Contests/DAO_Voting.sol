// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    address public owner;
    bool public DAOInitialized;
    uint256 public contributionTimeEnd;
    uint256 public voteTime;
    uint256 public quorum;
    mapping(address=>uint256) public balances;
    address[] public investors;
    enum Status{Pending, Approved, Rejected}
    struct Proposal{
        uint256 proposalId;
        string description;
        uint amount;
        address receipient;
        Status status;
        uint256 totalVotes;
    }
    Proposal[] public proposals;
    mapping(address=>bool) public voted;

    error DAONotInitialized();
    error InvalidConfig();

    constructor()
    {
        owner = msg.sender;
    }

    function initializeDAO(
        uint256 _contributionTimeEnd,
        uint256 _voteTime,
        uint256 _quorum
    ) public {
        require(msg.sender==owner, 'Only owner can initialize DAO');
        if(_contributionTimeEnd == 0 || _voteTime == 0 || _quorum == 0) revert InvalidConfig();
        require(!DAOInitialized,"DAO already initialized");
        DAOInitialized=true;
        contributionTimeEnd=block.timestamp+_contributionTimeEnd;
        voteTime=contributionTimeEnd+_voteTime;
        quorum=_quorum;
    }


    function contribution() public payable {
        require(DAOInitialized,"DAO not initialized");
        require(msg.value>0,"The contribution amount should be greater than 0");
        require(block.timestamp<contributionTimeEnd,"Contribution time has ended");
        (bool success,) = address(this).call{value:msg.value}("");
        require(success,"Contribution Failed");
        balances[msg.sender]+=msg.value;
        investors.push(msg.sender);
    }

    modifier sharesCheck(uint _amount)
    {
        require(balances[msg.sender]>=_amount,"Insufficient Shares");
        require(address(this).balance>=_amount,"DAO has insufficient balance");
        _;
    }

    function reedemShare(uint256 amount) public sharesCheck(amount){
        (bool success,)=payable(msg.sender).call{value:amount}("");
        require(success,"Transfer Failed");
        balances[msg.sender]-=amount;
    }
    function inArray(address _user) internal view returns(bool)
    {
        for(uint i=0;i<investors.length;)
        {
            if(investors[i]==_user)
            {
                return true;
            }
            unchecked{
                i++;
            }
        }
        return false;
    }

    function transferShare(uint256 amount, address to) public sharesCheck(amount) {
        require(amount>0,"Zero transfer");
        balances[msg.sender]-=amount;
        balances[to]+=amount;
        if(!inArray(to))
        {
            investors.push(to);
        }
    }

    function createProposal(string calldata _description,uint256 _amount,address payable _receipient) public {
        require(DAOInitialized,"DAO not initialized");
        require(msg.sender==owner,"Only the owner can create proposal");
        require(address(this).balance>=_amount,"The DAO has insufficient funds");
        Proposal memory proposal = Proposal({proposalId: proposals.length,description: _description, amount: _amount, receipient: _receipient, status: Status.Pending,totalVotes:0});
        proposals.push(proposal);
    }

    function voteProposal(uint256 proposalId) public {
        require(inArray(msg.sender),"The voter is not an investor");
        require(block.timestamp<voteTime,"Voting period over");
        require(!voted[msg.sender],"Person already voted");
        proposals[proposalId].totalVotes+=balances[msg.sender];
        voted[msg.sender]=true;
    }

    function executeProposal(uint256 proposalId) public {
        require(msg.sender==owner,"Only owner can call this function");
        require(block.timestamp>voteTime,"Voting period is not over");
        if(proposals[proposalId].totalVotes>((quorum*(address(this).balance)/100)))
        {
            (bool success, )=proposals[proposalId].receipient.call{value: proposals[proposalId].amount}("");
            require(success,"Failed to send amount to the receipient");
            proposals[proposalId].status=Status.Approved;
        }
        else
        {
            proposals[proposalId].status=Status.Rejected;
        }
        
    }

    function proposalList() public view returns (string[] memory ,uint[] memory,address[] memory) {
        if(proposals.length==0) revert DAONotInitialized();
        uint256 len=proposals.length;
        string[] memory descriptions = new string[](len);
        uint[] memory amounts= new uint[](len);
        address[] memory receipients = new address[](len);

        for(uint i=0;i<len;i++)
        {
            descriptions[i]=proposals[i].description;
            amounts[i] = proposals[i].amount;
            receipients[i] = proposals[i].receipient;
        }
        return(descriptions, amounts, receipients);
    }

    function allInvestorList() public view returns (address[] memory) {
        if(investors.length==0) revert DAONotInitialized();
        return investors; 
    }

    receive() external payable { }
}