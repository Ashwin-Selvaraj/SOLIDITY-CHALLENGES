// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyContract {
    address[] public members;
    address internal owner;
    constructor()
    {
        owner=msg.sender;
    }
    // modifier is used to check whether a person is already a club member or not
    modifier club_Member(){
        for(uint8 i=0;i<members.length;i++)
        {
            require(msg.sender!=members[i],"The joiner is already a member of this club");
        }
        _;
    }
    function join() public payable club_Member() 
    {
        require(msg.value==1 ether,"You should pay 1 ETH to join the club");
        (bool success,)=owner.call{value:msg.value}("");
        require(success,"Amount failed to deposit");
        members.push(msg.sender);
    }

    function join_referrer(address referrer)public payable club_Member(){
        bool is_a_member;
        for(uint8 i=0;i<members.length;i++)
        {
            if(referrer==members[i])
            {
                is_a_member=true;
                break ;
            }
            else {
                is_a_member=false;
            }
        }
        require(is_a_member,"The referrer is not a member");
        require(msg.value==1 ether,"You should pay 1 ETH to join the club");
        (bool success1,)=owner.call{value:0.9 ether}("");
        (bool success2,)=referrer.call{value:0.1 ether}("");
        require((success1&&success2),"Amount failed to deposit");
        members.push(msg.sender);
    }

    function get_members()public view returns(address[] memory)
    {
        return members;
    }  
}