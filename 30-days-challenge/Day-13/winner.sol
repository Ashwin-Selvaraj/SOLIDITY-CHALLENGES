// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DWGotTalent {
    address[] public judges;
    address[] public finalists;
    address private owner;
    bool public weightageAdded;
    enum Voting{
        preparation,
        started,
        ended
    }
    Voting isVoting;
    uint public audienceWeightage;
    uint public judgeWeightage;
    // mapping to find whether a person is already voted or not
    mapping(address=>address) public votedAddress;
    // mapping to find no of votes
    mapping(address=>uint) public noOfVotes;

    constructor()
    {
        owner=msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender==owner,"only the owner of the contract can call this function");
        _;
    }

    function inArray(address[] memory arr, address check_address) internal pure returns(bool) {
        for(uint i; i < arr.length; i++) {
            if(arr[i] == check_address) {
                return true;
            }
        }
        return false;
    }
    //this function defines the addresses of accounts of judges
    function selectJudges(address[] memory arrayOfAddresses) public onlyOwner{
        require(isVoting==Voting.preparation,"voting  is already started cannot modify");
        require(inArray(arrayOfAddresses, owner) == false);
        for(uint i; i < finalists.length; i++) {
            require(inArray(arrayOfAddresses, finalists[i]) == false);
        }
        judges=arrayOfAddresses;
    }

    //this function adds the weightage for judges and audiences
    function inputWeightage(uint _judgeWeightage, uint _audienceWeightage) public {
        require(isVoting==Voting.preparation,"voting  is already started cannot modify");
        audienceWeightage=_audienceWeightage;
        judgeWeightage=_judgeWeightage;
        weightageAdded=true;
    }

    //this function defines the addresses of finalists
    function selectFinalists(address[] memory arrayOfAddresses) public onlyOwner
    {
        require(isVoting==Voting.preparation,"voting  is already started cannot modify");
        require(inArray(arrayOfAddresses, owner) == false);
        for(uint i; i < judges.length; i++) {
            require(inArray(arrayOfAddresses, judges[i]) == false);
        }
        finalists=arrayOfAddresses;
    }

    //this function strats the voting process
    function startVoting() public onlyOwner {
        require(weightageAdded && judges.length>0 && finalists.length>0 ==true,"cannot start the voting process");
        isVoting = Voting.started;
    }

    function vote(address _finalistAddress, uint _weightage) internal {
        address addr = votedAddress[msg.sender];
        if(addr != address(0)) {
            noOfVotes[addr] -= _weightage;
        }
        noOfVotes[_finalistAddress] += _weightage;
    }
    //this function is used to cast the vote 
    function castVote(address finalistAddress) public {
        require(isVoting==Voting.started,"Voting is not yet started/already finished");
        require(inArray(finalists, finalistAddress) == true);
        if(inArray(judges, msg.sender) == true ) {
            vote(finalistAddress, judgeWeightage);
        } else {
            vote(finalistAddress, audienceWeightage);
        }
    }

    //this function ends the process of voting
    function endVoting() public onlyOwner{
        require(isVoting==Voting.started);
        isVoting=Voting.ended;
    }

    //this function returns the winner/winners
    function showResult() public view returns (address[] memory) {
        require(isVoting==Voting.ended);
        uint max=0;
        uint count=1;
        for(uint i=0;i<finalists.length;i++)
        {
            if(noOfVotes[finalists[i]]==max)
            {
                count++;
            }
            else if(noOfVotes[finalists[i]]>max)
            {
                max=noOfVotes[finalists[i]];
                count=1;
            }
        }
        address[] memory winners=new address[](count);
        count=0;
        for(uint i=0;i<finalists.length;i++)
        {
            if(noOfVotes[finalists[i]]==max)
            {
                winners[count++]=finalists[i];
            }
        }
        return winners;
    }

}