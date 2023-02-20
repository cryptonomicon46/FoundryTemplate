// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "../src/Permit2Vault.sol";
import "./TestUtils.sol";
import "../../src/Permit2Clone.sol";
import "../../src/ReenteringERC20.sol";

// import {IERC20, IPermit2} from "../../src/Permit2Interfaces.sol";

contract Permit2VaultTest is TestUtils {
    bytes32 constant TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");
    bytes32 constant PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );
  Permit2Clone permit2 = new Permit2Clone();
    TestERC20 token = new TestERC20();
    ReenteringERC20 badToken = new ReenteringERC20();
    Permit2Vault vault;
    uint256 ownerKey;
    address owner;
    constructor() {
        vm.chainId(1);
        vault = new Permit2Vault(permit2);
        ownerKey = _randomUint256();
        owner = vm.addr(ownerKey);
        vm.prank(owner);
        token.approve(address(permit2), type(uint256).max);
    }

 function testCanDeposit() external {
        uint256 amount = _randomUint256() % 1e18 + 1;
        token.mint(owner, amount);
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(token)),
                amount: amount
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
        assertEq(vault.tokenBalancesByUser(owner, IERC20(address(token))), amount);
        assertEq(token.balanceOf(address(vault)), amount);
        assertEq(token.balanceOf(owner), 0);
    }


   function testCannotReusePermit() external {
        uint256 amount = _randomUint256() % 1e18 + 1;
        token.mint(owner, amount);
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(token)),
                amount: amount
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
        vm.expectRevert(abi.encodeWithSelector(Permit2Clone.InvalidNonce.selector));
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
    }

        function testCannotUseOthersPermit() external {
        uint256 amount = _randomUint256() % 1e18 + 1;
        token.mint(owner, amount);
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(token)),
                amount: amount
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        vm.expectRevert(abi.encodeWithSelector(Permit2Clone.InvalidSigner.selector));
        vm.prank(_randomAddress());
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
    }


   function _signPermit (
        IPermit2.PermitTransferFrom memory permit,
        address spender,
        uint256 signerKey
    )
        internal view 
        returns (bytes memory sig)
    {
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(signerKey, _getEIP712Hash(permit, spender));
        return abi.encodePacked(r, s, v);
    }

        // Compute the EIP712 hash of the permit object.
    // Normally this would be implemented off-chain.
    function _getEIP712Hash(IPermit2.PermitTransferFrom memory permit, address spender)
        internal
        view
        returns (bytes32 h)
    {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            permit2.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                PERMIT_TRANSFER_FROM_TYPEHASH,
                keccak256(abi.encode(
                    TOKEN_PERMISSIONS_TYPEHASH,
                    permit.permitted.token,
                    permit.permitted.amount
                )),
                spender,
                permit.nonce,
                permit.deadline
            ))
        ));
    }


      function testCanWithdraw() external {
        uint256 amount = _randomUint256() % 1e18 + 2;
        token.mint(owner, amount);
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(token)),
                amount: amount
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
        vm.prank(owner);
        vault.withdrawERC20(IERC20(address(token)), amount - 1);
        assertEq(token.balanceOf(owner), amount - 1);
        assertEq(token.balanceOf(address(vault)), 1);
    }


    function testCannotWithdrawOthers() external {
        uint256 amount = _randomUint256() % 1e18 + 1;
        token.mint(owner, amount);
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(token)),
                amount: amount
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(token)),
            amount,
            permit,
            sig
        );
        vm.expectRevert();
        vm.prank(_randomAddress());
        vault.withdrawERC20(IERC20(address(token)), amount);
    }



    function testCannotReenter() external {
        IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({
                token: IERC20(address(badToken)),
                amount: 0
            }),
            nonce: _randomUint256(),
            deadline: block.timestamp
        });
        bytes memory sig = _signPermit(permit, address(vault), ownerKey);
        // Reenter by calling withdrawERC20() in transferFrom()
        badToken.setReentrantCall(
            address(vault),
            abi.encodeCall(vault.withdrawERC20, (IERC20(address(badToken)), 0))
        );
        // Will manifest as a TRANSFER_FROM_FAILED
        vm.expectRevert('TRANSFER_FROM_FAILED');
        vm.prank(owner);
        vault.depositERC20(
            IERC20(address(badToken)),
            0,
            permit,
            sig
        );
    }

}




contract TestERC20 is ERC20 {
    constructor() ERC20("Test", "TST", 18) {}

    function mint(address owner, uint256 amount) external {
        _mint(owner, amount);
    }
}



