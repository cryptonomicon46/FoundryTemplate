// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Safe.sol";

contract SafeTest is Test {
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);

    Safe safe;
    receive() external payable {}

    function setUp() public {
        safe= new Safe();
    }


    function testTransferEvent() public {
        vm.expectEmit(true,true,false,false);
        emit Transfer(address(this), address(safe), 2 ether);
        payable(address(safe)).transfer(2 ether);
    }

    /**
     * @dev the default amount given to a contract is 2**96 wei,so we have to restrict the amount to uint96
     * @dev exclude <0.1 ether by using vm.assume
     */

    function testWithdraw(uint96 amount) public {
        vm.assume(amount > 0.1 ether);
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(safe).balance;
        safe.withdraw();
        uint256 postBalance = address(safe).balance;
        assertEq(postBalance+ amount, preBalance);

    }
}