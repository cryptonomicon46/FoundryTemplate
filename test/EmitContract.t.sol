// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/ExpectEmit.sol";

contract EmitContractTest is Test {


    event Transfer(address indexed from, address indexed to, uint256 amount);
    ExpectEmit emitter;
    function setUp() public  {
        emitter = new ExpectEmit();


    }
    function testExpectEmit() public {
        vm.expectEmit(true,true,false,true);
         emit Transfer(address(this),address(1337),1337);
         emitter.t();
    }


    function testExpectEmitDoNotCheckData() public {
        vm.expectEmit(true,true,false,false);
         emit Transfer(address(this),address(1337),1338);
         emitter.t();
    }

    // function testExpectEmitDoNotCheckData() public {

    // }
}