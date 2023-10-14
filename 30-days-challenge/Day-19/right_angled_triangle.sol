// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RightAngledTriangle {
    //To check if a triangle with side lenghts a,b,c is a right angled triangle
    function check(uint a, uint b, uint c) external pure returns (bool) {
        if((a>b&&a>c))
        {
            return a*a == b*b + c*c;
        }
        else if((a<b&&b>c))
        {
            return b*b == a*a  + c*c;
        }
        else
        {
            return c*c == a*a  + b*b;
        }
    }
}