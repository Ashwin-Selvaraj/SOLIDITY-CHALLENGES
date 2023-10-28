// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PalindromeChecker {
    
    //To check if a given string is palindrome or not
    function isPalindrome(string memory _str)external pure returns (bool){
        bytes memory str=bytes(_str);
        
        uint len = str.length;
        
    }
}
