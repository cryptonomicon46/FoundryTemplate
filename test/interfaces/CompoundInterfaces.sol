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
    function repayBorrow(uint repayAmount) external returns (uint);
    function approve(address account, uint256 amount) external returns (bool);
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
    function getCash() external returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function totalReserves() external returns (uint);
    function totalSupply() external returns (uint);
        function borrow(uint) external returns (uint);



}

interface ICOMP {
    function balanceOf(address account) external returns (uint);
    function transfer(address dst,uint amount) external returns  (bool);
    function transferFrom(address spender,address dst, uint256 amount) external returns (bool);
    

}

interface IComptroller{
    function enterMarkets(address[] memory) external returns (uint256[] memory);
    function mintAllowed(address cToken, address minter, uint256 mintAmount) external returns (uint256);
    function exitMarket(address cTokenAddress) external returns (uint256);
    function checkMembership(address account, address cToken) external returns (bool);
    function getAssetsIn(address account) external returns (address[] memory);
    function redeemAllowed(address cToken, address account, uint256 redeemTokens) external returns (uint256);
    function repayBorrowAllowed(address cToken, address payer, address borrower, uint repayAmount) external returns (uint256);
    function liquidateBorrowAllowed(address cTokenBorrowed,address cTokenCollateral, address liquidator, address borrower, uint256 repayAmount) external returns (uint256);
   function siezeAllowed(address cTokenCollateral, address cTokenBorrowed, address liquidator, address borrower, uint256 siezeTokens) external returns (uint);
    function transferAllowed(address cToken, address src, address dst, uint256 transferTokens) external returns (uint256);
    function getAccountLiquidity(address account) external returns (uint256, uint256,uint256);
    function markets(address cToken) external returns (bool,uint256,bool);
    function closeFactorMantissa() external view returns (uint256);
     function claimComp(address holder) external;
     function claimComp(address  holder, address[] memory cTokens) external;


}