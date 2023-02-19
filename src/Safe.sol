// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Safe {

    receive() external payable{
        emit Transfer(msg.sender, address(this), msg.value);
    }

    event Transfer(address indexed sender, address indexed receiver, uint256 amount);


    function withdraw() external {
        uint256 bal = address(this).balance;
        payable(msg.sender).transfer(bal);
        emit Transfer(address(this),msg.sender,bal);
    }




}