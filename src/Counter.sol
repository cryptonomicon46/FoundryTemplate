// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    address public immutable owner;    
    error Unauthorized();
    constructor () {
        owner = msg.sender;
    }
    function setNumber(uint256 newNumber) public {

        number = newNumber;
    }

    function increment() public {
        if(msg.sender != owner) {revert Unauthorized();}
        number++;
    }
}
