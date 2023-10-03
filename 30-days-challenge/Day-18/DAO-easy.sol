// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    address public owner;
    address[] public members;
    mapping(address=>bool) public memberRegistered;
    mapping(address=>mapping(address=>bool)) public memberVoted;
    mapping(address=>uint) public noOfVotes;
    constructor()
    {
        owner=msg.sender;
        members.push(msg.sender);
    }
    function inArray(address[] memory arr,address member) public pure returns(bool)
    {
        uint len=arr.length;
        for(uint i;i<len;)
        {
            if(arr[i]==member) return true;
            unchecked{i++;}
        }
        return false;
    }
    //To apply for membership of DAO
    function applyForEntry() public {
        require(!inArray(members,msg.sender),"Only non-members can access this function");
        require(!memberRegistered[msg.sender],"member alreadyRegisted");
        memberRegistered[msg.sender]=true;
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address applicant) public {
        require(inArray(members,msg.sender),"This function is accessible only to the members of the DAO");
        require(memberRegistered[applicant],"Applicant is not registered");
        require(!inArray(members,applicant),"The Applicant is already a member");
        require(!memberVoted[msg.sender][applicant],"Already Voted");
        ++noOfVotes[applicant];
        memberVoted[msg.sender][applicant]=true;
        if((noOfVotes[applicant]*100)/members.length>=30)
        {
            members.push(applicant);
        }
    }

    //To check membership of DAO
    function isMember(address _user) public view returns (bool) {
        require(inArray(members,msg.sender),"Only accessible to the members of the DAO");
        return inArray(members,_user);
    }

    //To check total number of members of the DAO
    function totalMembers() public view returns (uint256) 
    {
        require(inArray(members,msg.sender),"Only accessible to the members of the DAO");
        return members.length;
    }
}
