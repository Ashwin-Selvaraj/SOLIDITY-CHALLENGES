// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AshonTech is ERC20,Ownable
{
    constructor(uint initialSupply) ERC20("ASHONTECH","AOT")
    {
        _mint(_msgSender(), initialSupply);
    }

    function mint(address account,uint256 amount) public  onlyOwner returns(bool)
    {
        require((account!=address(this)) && amount!=uint256(0),"Invalid ERC20 inputs:address,amount");
        _mint(account, amount);
        return true;
    }

    function burn(address account,uint256 amount) public onlyOwner returns(bool)
    {
        require((account!=address(this)) && amount!=uint256(0),"Invalid ERC20 inputs:address,amount");
        _burn(account, amount);
        return true;
    }

    function buy() public payable returns(bool)
    {
        require(_msgSender().balance>= msg.value && msg.value!=0 ether,"ICO: function buy invalid input");
        uint amount = msg.value*1000/1000000000000000000;
        _transfer(owner(), _msgSender(), amount);
        return true;
    }

    function withdraw(uint amount) public onlyOwner returns (bool)
    {
        require(amount<=address(this).balance,"ICO: function withdraw has invalid input");
        (bool success,)=msg.sender.call{value:amount}("");
        return success;
    }

}


