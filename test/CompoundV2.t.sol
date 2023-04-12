// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "../lib/forge-std/src/Test.sol";
import "forge-std/Test.sol";

import "../lib/forge-std/src/console2.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/CheatCodes.sol";
import "./interfaces/CompoundInterfaces.sol";



contract CompoundV2Test is Test {
      CERC20 cDAI = CERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

      CERC20 cUSDC = CERC20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);

    CETH cETH = CETH(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    CERC20 cWBTC = CERC20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IComptroller comptroller = IComptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
     address here = address(this);




    function setUp() public {
    console.log("This contract's address = %s", here);
    vm.createSelectFork("mainnet",17_033_152);
     vm.label(address(cDAI),"cDAI");
     vm.label(address(dai),"dai");
     vm.label(address(cETH),"cETH");
     vm.label(address(comptroller),"comptroller");
     vm.label(address(this),"here");


    }
    

    function testMint_cDAI() public {
    deal(address(dai),here,4000 ether);
    emit log_uint(dai.balanceOf(here));
    dai.approve(address(cDAI),100 ether);
    assert(cDAI.mint(100 ether)==0);
    emit log_uint(cDAI.balanceOfUnderlying(here));
    emit log_uint(cDAI.balanceOf(here));
    emit log_uint(cDAI.exchangeRateCurrent()/10**(18));
    emit log_uint(cDAI.getCash());
    emit log_uint(cDAI.totalBorrowsCurrent());

    }

    function testExchangeRate_DAI() public  {
        emit log_named_decimal_uint("Underlying(dai) cash reserves",cDAI.getCash(),18);
        emit log_named_decimal_uint("Underlying(dai) totalBorrows:",cDAI.totalBorrowsCurrent(),18);
        uint initialTotalBorrows = cDAI.totalBorrowsCurrent();
        emit log_named_decimal_uint("cDAI totalReserves",cDAI.totalReserves(),8);
        emit log_named_uint("cDAI totalSupply:",cDAI.totalSupply());
        emit log_named_uint("cDAI Balance of this contract:",cDAI.balanceOf(here));
        emit log_named_decimal_uint("cDAI Balance of contract before mint:", cDAI.balanceOf(here),8);
        uint calcExchangeRate = (cDAI.getCash() + cDAI.totalBorrowsCurrent()- cDAI.totalReserves())/cDAI.totalSupply();
    //    calcExchangeRate = calcExchangeRate/10**10;

        emit log_named_decimal_uint("Calculated Exchange Rate:",calcExchangeRate,(10));
        uint expectedcDAIBal = 10_000 ether/calcExchangeRate;
        emit log_named_decimal_uint("Calculated Underlying before mint", expectedcDAIBal,8);
        emit log_named_decimal_uint("Current Exchange Rate:",cDAI.exchangeRateCurrent(),(18-8+18));

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDAI),10_000 ether);
        assert(cDAI.mint(10_000 ether)==0);
        emit log_named_uint("cDAI Balance of this contract after minting:",cDAI.balanceOf(here));
        emit log_named_decimal_uint("cDAI Balance of contract after mint:", cDAI.balanceOf(here),8);
        emit log_named_decimal_uint("Dai underlying balance after mint:", cDAI.balanceOfUnderlying(here),18);
        uint obs_cDAIBal = cDAI.balanceOf(here);
        assertLt((expectedcDAIBal-obs_cDAIBal),0.01 ether);
        skip(100_000_000);
        emit log_named_decimal_uint("Exchange rate after skip:",cDAI.exchangeRateCurrent(),(18-8+18));
        emit log_named_decimal_uint("cDAI totalReserves after skip",cDAI.totalReserves(),8);




    }


  function testBorrow_DAI() public  {

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDAI),10_000 ether);
        assert(cDAI.mint(10_000 ether)==0);
        emit log_uint(cDAI.getCash());
        emit log_uint(cDAI.totalBorrowsCurrent());
        uint initialTotalBorrows = cDAI.totalBorrowsCurrent();
        emit log_named_decimal_uint("TotalBorrows before borrow:",cDAI.totalBorrowsCurrent(),18);

        emit log_uint(cDAI.getCash());

            emit log_named_decimal_uint("Borrowbalance beforte borrowing :",cDAI.borrowBalanceCurrent(here),18);

        assert(cDAI.borrow(1000 ether) ==0);
        uint finalTotalBorrows = cDAI.totalBorrowsCurrent();
        emit log_named_decimal_uint("TotalBorrows After borrow:",cDAI.totalBorrowsCurrent(),18);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDAI.borrowBalanceCurrent(here),18);
        emit log_named_decimal_uint("Borrow rate per block",cDAI.borrowRatePerBlock(),18);
        emit log_named_decimal_uint("Reserve Factor",cDAI.reserveFactorMantissa(),18);
        assert(cDAI.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDAI.borrowBalanceCurrent(here),18);
        assert(cDAI.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDAI.borrowBalanceCurrent(here),18);
        assert(cDAI.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDAI.borrowBalanceCurrent(here),18);
        skip(10000000000);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDAI.borrowBalanceCurrent(here),18);

    }

    function testFail_BorrowDai() public {

        emit log_uint(cDAI.borrowBalanceCurrent(here));

        assert(cDAI.borrow(1000 ether) ==0);

    }

    function testSupply_ETH() public{
        vm.deal(here, 1000 ether); 
    
        uint256 initialBalETH = address(this).balance;
        // emit log_named_decimal_uint("cETH underlying balance", cETH.getCash(),18);
        emit log_named_uint("Initial cETH balance of this contract:", cETH.balanceOf(here));
        cETH.mint{value: 1000 ether}();
        emit log_named_decimal_uint("cETH balance after calling mint:", cETH.balanceOf(here),0);

        uint256 calcExchangeRate = 1e18*(cETH.getCash() + cETH.totalBorrowsCurrent() - cETH.totalReserves())/cETH.totalSupply();
        uint256 calculatedMinted = (1000 ether *1e18)/calcExchangeRate;
        emit log_named_decimal_uint("Calculated Exchange Rate", calcExchangeRate,0);
        emit log_named_decimal_uint("Calculated minted tokens", calculatedMinted,0);
        emit log_named_decimal_uint("Exchange rate", cETH.exchangeRateCurrent(),(0)); 
       emit log_named_uint("Calculated minted", calculatedMinted);
       uint256 actualMinted_cETH = cETH.balanceOf(here);
       emit log_named_uint("Actual minted before block advance", actualMinted_cETH);
       assertEq(calculatedMinted,actualMinted_cETH);

       vm.roll(block.number+50000);
       uint256 currentBalanceMinted  = cETH.balanceOf(here);
       emit log_named_uint("Minted balance after block advance", currentBalanceMinted);
       assertEq(cETH.redeem(currentBalanceMinted),0);
       assertEq(cETH.balanceOf(here),0);
       uint256 finalBalETH  = address(this).balance;
      emit log_named_decimal_uint("ETH Balance after redeem", finalBalETH,18);





    }
    function testEnterMarket_ETH() public {
        address[] memory cTokens = new address[](1);
        uint[] memory results = new uint[](1);
        cTokens[0] = address(cETH);

        assertFalse(comptroller.checkMembership(here,cTokens[0]));
        console.log("Checking membership before minting");
        console.logBool(comptroller.checkMembership(here,cTokens[0]));
        results = comptroller.enterMarkets(cTokens);
        emit log_named_uint("Entered cETH market check (pre mint)", results[0]);

        vm.deal(here, 1000 ether);
        cETH.mint{value: 1000 ether}();
        results = comptroller.enterMarkets(cTokens);
        emit log_named_uint("This contract's cETH balance:", cETH.balanceOf(here));
        emit log_named_uint("Entered cETH market check (post mint)", results[0]);
        assertTrue(comptroller.checkMembership(here,cTokens[0]));
        console.log("Checking membership after minting");
        console.logBool(comptroller.checkMembership(here,cTokens[0]));


        (,uint256 collateralFactor,) = comptroller.markets(cTokens[0]);
        emit log_named_decimal_uint("CollateralFactor:", collateralFactor,18);


        (,uint256 accountLiquidity,) = comptroller.getAccountLiquidity(here);
        emit log_named_decimal_uint("Account liquidity before borrowing cDAI", accountLiquidity,18);

        emit log_named_decimal_uint("cEth balance of here", cETH.balanceOf(here),8);

    }

    function testMint_cWBTC() public {
        deal(address(wbtc), here, 1000e8);
        wbtc.approve(address(cWBTC), 1000e8);
        assert(cWBTC.mint(1000e8)==0);    
        uint initial_cWBTCBal = cWBTC.balanceOf(here);
        emit log_uint(initial_cWBTCBal);

        // emit log_uint(cWBTC.balanceOfUnderlying(here));
        // emit log_uint(cWBTC.exchangeRateCurrent()/10**8);
        // emit log_uint(cWBTC.totalBorrowsCurrent());
        skip(31536000);
        uint final_cWBTCBal = cWBTC.balanceOf(here);
        emit log_uint(final_cWBTCBal);
        assertGt(final_cWBTCBal,initial_cWBTCBal);
        console.log("Interest Accural on cWBTC tokens");
        console.logUint(final_cWBTCBal - initial_cWBTCBal);




    }


    function testMint_cUSDC() public {
        deal(address(usdc),here, 5000e18);
        emit log_uint(usdc.balanceOf(here));
        usdc.approve(address(cUSDC),5000);
        assert(cUSDC.mint(5000)==0);
        emit log_uint(cUSDC.balanceOf(here));
        emit log_uint(cUSDC.balanceOfUnderlying(here));

    }



 
  receive() external payable {
    // require(msg.sender == address(cETH) || msg.sender == address(cDAI),"Invalid Sender");
    // contractETHBal += msg.value;
    // emit ETH_Received(msg.sender,msg.value);
  }
// event ETH_Received(address sender, uint256 amount);

}