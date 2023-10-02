// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Bookstore {
    address public owner;
    constructor(){
        owner=msg.sender;
    }
    uint ID=1;
    struct Book{
        string title;
        string author;
        string publication;
        bool available;
    }
    mapping (uint=>Book) public books;

    modifier onlyOwner()
    {
        require(msg.sender==owner,"only owner can call this function");
        _;
    }

    // this function can add a book and only accessible by gavin
    function addBook(string memory title, string memory author, string memory publication) public onlyOwner {
        books[ID]=Book(title,author,publication,true);
        ID+=1;
    }

    // this function makes book unavailable and only accessible by gavin
    function removeBook(uint id) public onlyOwner{
        if(!books[id].available || msg.sender!=owner || id==0 || id>ID) revert();
        books[id].available=false;
    }



    // this function modifies the book details and only accessible by gavin
    function updateDetails(
        uint id, 
        string memory title, 
        string memory author, 
        string memory publication, 
        bool available) public onlyOwner {
            if(id>=ID || id==0) revert();
            books[id] = Book(title, author, publication, available);
        }

    
    function compareString(string memory str1, string memory str2) private pure returns(bool)
    {
        if(bytes(str1).length!=bytes(str2).length) return false;
        else if(keccak256(abi.encodePacked(str1))==keccak256(abi.encodePacked(str2))) return true;
        else return false;
    }

    function trimArray(uint[] memory arr, uint count) private pure returns(uint[] memory) {
        uint[] memory ids = new uint[](count); 
        for(uint i; i < count; i++) {
            ids[i] = arr[i];
        }
        return ids;
    }
    // this function returns the ID of all books with given title
    function findBookByTitle(string memory title) public view returns (uint[] memory)  
    {
        uint[] memory ids=new uint[](ID);
        uint index=0;
        for(uint i=1;i<ID;i++)
        {
            if(msg.sender==owner || books[i].available)
            {
                if(compareString(books[i].title,title))
                {
                    ids[index]=i;
                    index+=1;
                }
            }
        }
        return trimArray(ids,index);
    }

    // this function returns the ID of all books with given publication
    function findAllBooksOfPublication (string memory publication) public view returns (uint[] memory)  {
        uint[] memory ids=new uint[](ID);
        uint index=0;
        for(uint i=1;i<ID;i++)
        {
            if(msg.sender==owner || books[i].available)
            {
                if(compareString(books[i].publication,publication))
                {
                    ids[index]=i;
                    index+=1;
                }
            }
        }
        return trimArray(ids,index);
    }

    // this function returns the ID of all books with given author
    function findAllBooksOfAuthor (string memory author) public view returns (uint[] memory)  
    {
        uint[] memory ids=new uint[](ID);
        uint index=0;
        for(uint i=1;i<ID;i++)
        {
            if(msg.sender==owner || books[i].available)
            {
                if(compareString(books[i].author,author))
                {
                    ids[index]=i;
                    index+=1;
                }
            }
        }
        return trimArray(ids,index);
    }

    // this function returns all the details of book with given ID
    function getDetailsById(uint id) external view returns (
        string memory title, 
        string memory author, 
        string memory publication, 
        bool available)  
        {
            if(id>=ID || id==0) revert();
            else if(msg.sender!=owner && !books[id].available) revert();
            else return (books[id].title, books[id].author, books[id].publication, books[id].available);
        }
}