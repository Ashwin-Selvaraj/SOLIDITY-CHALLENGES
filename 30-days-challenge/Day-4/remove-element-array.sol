// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

library Math {
    // a library will not have a state variable inside
    // This library is deployed to the blockchain. It is compiled and the functions byte code gets added to the contracts bytecode and gets deployed
    function removeIndex(uint[] storage array,uint index) public
    {
        require(index<array.length,"array index out of bound");
        for(uint i=0;i<array.length-1;i++)
        {
            if(index<=i)
            {
                array[i]=array[i+1];
            }
        }
        array.pop();
    }
}

// don't need to import the library, since it is present in the same solidity file

contract Test
{
    uint[] public array;
    using Math for uint[];

    // the function will create an array of random numbers between 0-99
    function createRandomArray() public {
        for(uint i=0;i<uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,i)))%10;i++)
        {
            array.push(uint(keccak256((abi.encodePacked(block.timestamp,msg.sender,i))))%100);
        }
    }
    // function to delete array
    function deleteArray() public 
    {
        while(array.length!=0)
        {
            array.pop();
        }
    }
    // function to view the array
    function showArray() public view returns(uint[] memory)
    {
        return array;
    }

    // function to delete element at a particular index
    function removeElementAtIndex(uint index) public 
    {
        array.removeIndex(index);
    }
}