//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface CERC20 {
    function balanceOf(address) external view returns (uint);
    function mint(uint) external returns (uint);
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlyintg(uint redeemAmount) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
  function balanceOfUnderlying(address) external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint256);  
    function decimals() external view returns (uint8);
    function reserveFactorMantissa() external returns (uint);
    function totalReserves() external returns (uint);
    function totalSupply() external returns (uint);
    function getCash() external returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrow(uint) external returns (uint);
    function borrowRatePerBlock() external returns (uint);
}

interface CETH {
    function balanceOf(address) external view returns (uint);
    function mint() external payable;
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlyintg(uint redeemAmount) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function balanceOfUnderlying(address owner) external view returns (uint256);
    function borrowBalanceCurrent(address account) external returns (uint256);
    function decimals() external view returns (uint8);
    function reserveFactorMantissa() external returns (uint);
    function totalReserves() external returns (uint);

}