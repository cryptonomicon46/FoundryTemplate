// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "ds-test/test.sol";
import "../src/Multicall.sol";
import "forge-std/console2.sol";

contract Store {
    uint256 internal val;
    function set(uint256 _val) public { val = _val; }
    function get() public view returns (uint256) { return val; }
    function getAnd10() public view returns (uint256, uint256) { return (val, 10); }
    function getAdd(uint256 _val) public view returns (uint256) { return val + _val; }
}

contract MultiCallTest is DSTest, Multicall {
    Store storeA;
    Store storeB;

    function setUp() public {
         storeA  = new Store();
         storeB = new Store();
    }

    function testStoreSanity() external {
        assertEq(storeA.get(), 0);
        storeA.set(10);
        assertEq(storeA.get(),10);
        storeA.set(0);
        assertEq(storeA.get(),0);
    }


    function testSingleCall() external {

        storeA.set(123);
        Call[] memory _calls = new Call[](1);
        _calls[0].target = address(storeA);
        _calls[0].callData = abi.encodeWithSignature("get()");

        (,bytes[] memory returnData) =  aggregate(_calls);
        bytes memory _word = returnData[0];
        uint256 _retLen;
        uint256 _retVal;
        assembly {
            _retLen := mload(add(0x00,_word))
            _retVal := mload(add(0x20,_word))

        }
        assertEq(_retVal,123);

        
    }


        function testMultiCall() external {

        storeA.set(100);
        storeB.set(500);
        Call[] memory _calls = new Call[](2);
        _calls[0].target = address(storeA);
        _calls[0].callData = abi.encodeWithSignature("get()");
        _calls[1].target = address(storeB);
        _calls[1].callData = abi.encodeWithSignature("get()");

        (,bytes[] memory _returnData) =  aggregate(_calls);
        bytes memory _wordA = _returnData[0];
        bytes memory _wordB = _returnData[1];
        uint256 _retValA;
        uint256 _retValB;
        assembly {
            _retValA := mload(add(0x20,_wordA))
        }
        assembly {
            _retValB := mload(add(0x20,_wordB))
        }
        assertEq(_retValA,100);
        assertEq(_retValB,500);

        
    }



    function testSingleCallMultiReturns() external {
        storeA.set(123);

        Call[] memory _calls = new Call[](1);
        _calls[0].target = address(storeA);
        _calls[0].callData = abi.encodeWithSignature("getAnd10()");
        (,bytes[] memory _returnData) =  aggregate(_calls);

        bytes memory _words = _returnData[0];
        uint256 _retValA1;
        uint256 _retValA2;
        assembly {
            _retValA1 := mload(add(0x20,_words))
            _retValA2 := mload(add(0x40,_words))

        }
        assertEq(_retValA1, 123);
        assertEq(_retValA2, 10);


     }
}