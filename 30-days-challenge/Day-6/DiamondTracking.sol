// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DiamondLedger {
    mapping(uint => uint) private map;

    //this function imports the diamonds
    function importDiamonds(uint[] calldata weights) public {
        for (uint i; i < weights.length;) {
            unchecked {
                ++map[weights[i]];
                ++i;
            }
        }
    }

    //this function returns the total number of available diamonds as per the weight
    function availableDiamonds(uint weight) public view returns(uint) {
        return map[weight];
    }
}


/* The ‘unchecked’ keyword is used in Solidity to inform the compiler that a particular operation should be performed without any checks.
By default, Solidity performs various validations and checks during code execution, such as array bounds checking, integer overflow checking,
and division by zero checking. These checks ensure that the code behaves as expected and prevents potential vulnerabilities.
When ‘unchecked’ is used, Solidity skips these default checks and assumes that the operation will not result in any issues. 
This can significantly reduce the gas cost of the operation, as the checks themselves consume computational resources. 
However, it is important to note that by using ‘unchecked,’ developers assume the responsibility of ensuring the correctness 
and safety of the operation being performed.*/