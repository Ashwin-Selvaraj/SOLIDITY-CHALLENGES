// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    address private owner;
    address[] public merchants;
    address[] public students;
    mapping(address=>mapping(bytes32=>uint)) public availableCredits;
    bytes32 ALL = keccak256(abi.encodePacked("all"));
    bytes32 MEAL = keccak256(abi.encodePacked("meal"));
    bytes32 ACADEMICS = keccak256(abi.encodePacked("academics"));
    bytes32 SPORTS = keccak256(abi.encodePacked("sports"));
    // mapping to find out the category
    mapping(address=>bytes32) public merchantCategory;
    constructor()
    {
        owner=msg.sender;
        availableCredits[msg.sender][ALL]=1000000;
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
    function grantScholarship(address studentAddress, uint credits, string memory category) external {
        require(msg.sender!=studentAddress,"Owner cannot be a student");
        require(!inArray(merchants,studentAddress),"Merchant cannot be a student");
        require(credits<=availableCredits[owner][ALL],"Insufficient credits");
        onlyOwner();
        bytes32 b_category= keccak256(abi.encodePacked(category));
        require(ALL == b_category ||MEAL == b_category ||ACADEMICS == b_category || SPORTS == b_category);
        availableCredits[studentAddress][b_category]+=credits;
        availableCredits[owner][ALL]-=credits;
        students.push(studentAddress);
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address merchantAddress, string memory category) external 
    {
        require(msg.sender!=merchantAddress,"Owner cannot be a Merchant");
        require(!inArray(students,merchantAddress),"Student cannot be a merchant");
        onlyOwner();
        bytes32 b_category= keccak256(abi.encodePacked(category));
        require(MEAL == b_category ||ACADEMICS == b_category || SPORTS == b_category);
        merchants.push(merchantAddress);
        merchantCategory[merchantAddress]=b_category;
    }

    function deleteMerchantOrStudent(address _addr) private 
    {
        unchecked {
            availableCredits[owner][ALL]+= availableCredits[_addr][MEAL];
            availableCredits[owner][ALL]+= availableCredits[_addr][ACADEMICS];
            availableCredits[owner][ALL]+= availableCredits[_addr][SPORTS];
            availableCredits[owner][ALL]+= availableCredits[_addr][ALL];
            availableCredits[_addr][MEAL] = 0;
            availableCredits[_addr][ACADEMICS] = 0;
            availableCredits[_addr][SPORTS] = 0;
            availableCredits[_addr][ALL] = 0;
        }
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress) external 
    {
        require(inArray(merchants,merchantAddress),"The address is not a merchant");
        onlyOwner();
        while(inArray(merchants,merchantAddress))
        {
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
        }
        deleteMerchantOrStudent(merchantAddress);
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) external{
        onlyOwner();
        require(inArray(students, studentAddress),"The address is not a student");
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
        students.pop();deleteMerchantOrStudent(studentAddress);
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint amount) external 
    {
        require(inArray(students,msg.sender),"Only students can access this function");
        require(inArray(merchants,merchantAddress),"The address is not a merchant");
        bytes32 merchant = merchantCategory[merchantAddress];
        require(uint256(merchant) > 1);
        unchecked {
            // if(merchant != ALL) {
            uint256 cat_funds = availableCredits[msg.sender][merchant];
            // }
            require((availableCredits[msg.sender][ALL] + cat_funds) >= amount);
            availableCredits[merchantAddress][ALL] += amount;
            if(cat_funds > amount) {
                cat_funds = amount;
                amount = 0;
            } else {
                amount -= cat_funds;
            }
            availableCredits[msg.sender][merchant] -= cat_funds;
            availableCredits[msg.sender][ALL] -= amount;
        }
    }

    //This function is used to see the available credits assigned.
    function checkBalance(string memory category) external view returns (uint)
    {
        require(inArray(students,msg.sender) || inArray(merchants,msg.sender) || msg.sender==owner);
        // bytes32 b_category= keccak256(abi.encodePacked(category));
        // return availableCredits[msg.sender][b_category];
        bytes32 b_categiry = keccak256(abi.encodePacked(category));
        if(inArray(students,msg.sender) || inArray(merchants,msg.sender)) {
            require(b_categiry == MEAL || 
                b_categiry == ACADEMICS || 
                b_categiry == SPORTS || 
                b_categiry == ALL);
            return availableCredits[msg.sender][b_categiry];
        } else if(msg.sender == owner) {
            if(b_categiry == ALL) {
                return availableCredits[owner][ALL];
            } else {
                return 0;
            }
        }
        revert();
    }
    //This function is used to see the category under which Merchants are registered
    function showCategory() public view returns (string memory){
        require(inArray(merchants,msg.sender),"The caller is not a merchant");
        bytes32 b_categiry = merchantCategory[msg.sender];
        if(b_categiry == MEAL) {
            return "meal";
        } else if(b_categiry == ACADEMICS) {
            return "academics";
        } else if(b_categiry == SPORTS) {
            return "sports";
        }
        revert();
    }
}