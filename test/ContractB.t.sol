// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
// import it indirectly via Test.sol
// or directly import it
import "forge-std/console2.sol";


contract ContractBTest is Test{
    uint256 testNumber;
    function setUp() public {
        testNumber = 42;
    }

    function testNumberis42() public {
        console2.log("Test Number is 42 test...");
        assertEq(testNumber,42);
    }

    function testFailSubtract43() public {
        console2.log("Test testFailSubtract43 test...");

        testNumber -=43;
    }

    function testCannotSubtract43() public {
    vm.expectRevert(stdError.arithmeticError);
    testNumber -= 43;
}
}