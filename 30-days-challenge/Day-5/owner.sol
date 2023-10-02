// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyContract {
    uint public num;
    address public owner;
// Solidity Events are the same as events in any other programming language.
// An event is an inheritable member of the contract, which stores the arguments passed in the transaction logs when emitted.
// We can also add an index to our event. On adding the different fields to our event, we can add an index to them it helps to access them later but of course, it’s going to cost some more gas!
    event deployed(address indexed);
    event ownerChange(address indexed previous_owner, address indexed present_owner);
    constructor()
    {
        owner=msg.sender;
        emit deployed(msg.sender);
    }
    // function to get the owner
    function get_owner() public view returns(address)
    {
        return owner;
    }
    modifier onlyOwner()
    {
        require(msg.sender==owner,"Only the current owner of this contract can able to access this function");
        _;
    }
    // function to change owner
    function change_owner(address new_owner) public onlyOwner{
        owner=new_owner;
        emit ownerChange(msg.sender, new_owner);

    }
    // function to store an unsigned integer
    function store(uint _number)public onlyOwner
    {
        num=_number;
    }
    // function to get the stored number
    function retrieve() public view returns(uint)
    {
        return num;
    }
}