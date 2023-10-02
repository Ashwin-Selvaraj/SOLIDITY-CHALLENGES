// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    address private owner;
    address[] public merchants;
    address[] public students;
    mapping(address=>uint) public availableCredits;
    constructor()
    {
        owner=msg.sender;
        availableCredits[msg.sender]=1000000;
    }

    function onlyOwner() private view 
    {
        require(msg.sender==owner,"Only owner can call this function");
    }
    function inArray(address[] memory arr,address checker)private pure returns(bool)
    {
        uint len=arr.length;
        uint i=0;
        for(;i<len;)
        {
            if(arr[i]==checker) return true;
            unchecked
            {
                i++;
            }
        }
        return false;
    }

    //This function assigns credits to student getting the scholarship
    function grantScholarship(address studentAddress, uint credits) external {
        require(msg.sender!=studentAddress,"Owner cannot be a student");
        require(!inArray(merchants,studentAddress),"Merchant cannot be a student");
        require(credits<=availableCredits[owner],"Insufficient credits");
        onlyOwner();
        availableCredits[studentAddress]+=credits;
        availableCredits[owner]-=credits;
        students.push(studentAddress);
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address merchantAddress) external 
    {
        require(msg.sender!=merchantAddress,"Owner cannot be a Merchant");
        require(!inArray(students,merchantAddress),"Student cannot be a merchant");
        onlyOwner();
        merchants.push(merchantAddress);
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress) external 
    {
        require(inArray(merchants,merchantAddress),"The address is not a merchant");
        onlyOwner();
        uint len=merchants.length;
        bool sts=false;
        for(uint i;i<len-1;)
        {
            if(sts)
            {
                merchants[i]=merchants[i+1];
            }
            else if(merchants[i]==merchantAddress)
            {
                merchants[i]=merchants[i+1];
                sts=true;
            }
            unchecked{i++;}
        }
        merchants.pop();
        availableCredits[owner]+=availableCredits[merchantAddress];
        delete availableCredits[merchantAddress];
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) external{
        onlyOwner();
        uint len=students.length;
        bool sts=false;
        for(uint i;i<len-1;)
        {
            if(sts)
            {
                students[i]=students[i+1];
            }
            else if(students[i]==studentAddress)
            {
                students[i]=students[i+1];
                sts=true;
            }
            unchecked{i++;}
        }
        students.pop();
        availableCredits[owner]+=availableCredits[studentAddress];
        delete availableCredits[studentAddress];
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint amount) external 
    {
        require(inArray(students,msg.sender),"Only students can access this function");
        require(inArray(merchants,merchantAddress),"The address is not a merchant");
        require(availableCredits[msg.sender]>=amount,"Insufficient credits");
        availableCredits[merchantAddress]+=amount;
        availableCredits[msg.sender]-=amount;
    }

    //This function is used to see the available credits assigned.
    function checkBalance() external view returns (uint)
    {
        require(inArray(students,msg.sender) || inArray(merchants,msg.sender) || msg.sender==owner);
        return availableCredits[msg.sender];
    }
}