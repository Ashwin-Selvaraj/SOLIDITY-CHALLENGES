// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
// This contract keeps all Ether sent to it with no way
// to get it back.
//  This is example code. Do not use it in production.
contract Sink {
    event Received(address, uint);
    string public name;
    receive() external payable {
        // Handle plain Ether transactions (no data)
        emit Received(msg.sender, msg.value);
        name="receive executed";
    }
    fallback() external payable{
        // Handle Ether transactions with arbitrary data
        name="fallback executed";
    }
}