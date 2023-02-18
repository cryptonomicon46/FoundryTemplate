// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
// import it indirectly via Test.sol
// or directly import it
import "forge-std/console2.sol";

contract CounterTest is Test {
    Counter public counter;

    error Unauthorized();

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function testIncrementAsOwner() public {
        console2.log("Test Increment function as owner...");
        assertEq(counter.number(),0);
        counter.increment();
        assertEq(counter.number(), 1);
    }
    
    function testFailIncNotByOwner() public {
        console2.log("Test Increment function not called by owner...");
        assertEq(counter.number(),0);
        vm.expectRevert(Unauthorized.selector);
        vm.prank(address(0));
        counter.increment();
        assertEq(counter.number(), 1);

    }
    function testSetNumber(uint256 x) public {
        console2.log("Test SetNumber function...");

        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
