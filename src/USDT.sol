// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20,Ownable{
    constructor (address owner) 
    ERC20("My Tokens","MT") 
    Ownable(owner) 
    {
        _mint(owner, 1000000);
    }

    function mint(address to, uint256 _amount) public onlyOwner returns(uint256) {
        _mint(to, _amount);
        return _amount;
    }
}