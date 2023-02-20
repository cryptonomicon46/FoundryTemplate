// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IERC20, IPermit2} from "./Permit2Interfaces.sol";
contract ReenteringERC20 {
    address _reentrantCallTarget;
    bytes _reentrantCallData;

    function setReentrantCall(address target, bytes calldata callData)
        external
    {
        _reentrantCallTarget = target;
        _reentrantCallData = callData;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        (bool s, bytes memory r) = _reentrantCallTarget.call(_reentrantCallData);
        if (!s) {
            assembly { revert(add(r, 0x20), mload(r)) }
        }
        return true;
    }
}