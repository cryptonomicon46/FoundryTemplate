// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "../lib/forge-std/src/Test.sol";
import "forge-std/Test.sol";

import "../lib/forge-std/src/console2.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/CheatCodes.sol";
import "./interfaces/CompoundInterfaces.sol";



contract CompoundV2Example is Test {
      CERC20 cDai = CERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

      CERC20 cUSDC = CERC20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);

    CETH cETH = CETH(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    CERC20 cWBTC = CERC20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
   CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
     address here = address(this);



    function setUp() public {
    
    console.log("This contract's address = %s", here);

    vm.createSelectFork("mainnet");
    //  vm.label(address(cDai),"cDaiAddress");
    //  vm.label(address(dai),"dai");
    //  vm.label(address(cETH),"cETH");



    // address daiWhale = 0xD831B3353Be1449d7131e92c8948539b1F18b86A;
    // address btcWhale = 0xEfa6DbC560308338867ab6Fa69a8C8f6BF14167E;
    // address usdcWhale = 0x1A8c53147E7b61C015159723408762fc60A34D17;

    // console.log("usdc whale",usdcWhale);
    // vm.prank(usdcWhale);
    // usdc.transfer(here,4000);
    // usdc.approve(address(cUSDC), 4000);



    // vm.prank(daiWhale);
    //  dai.transfer(here,1000);
    // dai.approve(address(cDai),1000);


    // console.log("This contract's dai balance");
    // console.logUint(dai.balanceOf(here));

    // vm.prank(btcWhale);
    // wbtc.transfer(address(this),5000);
    // wbtc.approve(address(cWBTC),5000);

    // console.log("This contract's wbtc balance");
    // console.logUint(wbtc.balanceOf(here));



    }
    

    function testMint_cDai() public {
    deal(address(dai),here,4000 ether);
    emit log_uint(dai.balanceOf(here));
    dai.approve(address(cDai),100 ether);
    assert(cDai.mint(100 ether)==0);
    emit log_uint(cDai.balanceOfUnderlying(here));
    emit log_uint(cDai.balanceOf(here));
    emit log_uint(cDai.exchangeRateCurrent()/10**(18));
    emit log_uint(cDai.getCash());
    emit log_uint(cDai.totalBorrowsCurrent());

    }

    function testExchangeRate_DAI() public  {
        emit log_uint(cDai.getCash());
        emit log_uint(cDai.totalBorrowsCurrent());
        uint initialTotalBorrows = cDai.totalBorrowsCurrent();
        emit log_uint(cDai.totalReserves());
        emit log_uint(cDai.totalSupply());
        emit log_uint(cDai.balanceOf(here));
        emit log_named_decimal_uint("cDai Balance of contract before mint:", cDai.balanceOf(here),8);
        uint calcExchangeRate = (cDai.getCash() + cDai.totalBorrowsCurrent()- cDai.totalReserves())/cDai.totalSupply();
    //    calcExchangeRate = calcExchangeRate/10**10;
        emit log_uint(calcExchangeRate);

        emit log_named_decimal_uint("Calculated Exchange Rate:",calcExchangeRate,(10));
        uint expectedcDaiBal = 10_000 ether/calcExchangeRate;
        emit log_named_decimal_uint("Expected Underlying Dai balance", expectedcDaiBal,8);
        emit log_named_decimal_uint("Current Exchange Rate:",cDai.exchangeRateCurrent(),(10));

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDai),10_000 ether);
        assert(cDai.mint(10_000 ether)==0);
        emit log_uint(cDai.balanceOf(here));
        emit log_named_decimal_uint("cDai Balance of contract after mint:", cDai.balanceOf(here),8);
        emit log_named_decimal_uint("Dai underlying balance after mint:", cDai.balanceOfUnderlying(here),18);
        uint obs_cDaiBal = cDai.balanceOf(here);
        assertLt((expectedcDaiBal-obs_cDaiBal),0.01 ether);




    }



  function testBorrow_DAI() public  {

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDai),10_000 ether);
        assert(cDai.mint(10_000 ether)==0);
        emit log_uint(cDai.getCash());
        emit log_uint(cDai.totalBorrowsCurrent());
        uint initialTotalBorrows = cDai.totalBorrowsCurrent();
        emit log_named_decimal_uint("TotalBorrows before borrow:",cDai.totalBorrowsCurrent(),18);

        emit log_uint(cDai.getCash());

            emit log_named_decimal_uint("Borrowbalance beforte borrowing :",cDai.borrowBalanceCurrent(here),18);

        assert(cDai.borrow(1000 ether) ==0);
        uint finalTotalBorrows = cDai.totalBorrowsCurrent();
        emit log_named_decimal_uint("TotalBorrows After borrow:",cDai.totalBorrowsCurrent(),18);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDai.borrowBalanceCurrent(here),18);
        emit log_named_decimal_uint("Borrow rate per block",cDai.borrowRatePerBlock(),18);
        emit log_named_decimal_uint("Reserve Factor",cDai.reserveFactorMantissa(),18);
        assert(cDai.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDai.borrowBalanceCurrent(here),18);
        assert(cDai.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDai.borrowBalanceCurrent(here),18);
        assert(cDai.borrow(1000 ether) ==0);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDai.borrowBalanceCurrent(here),18);
         skip(10000000000);
        emit log_named_decimal_uint("Borrowbalance after borrowing :",cDai.borrowBalanceCurrent(here),18);

    }
    function testETH() public {
        vm.deal(here, 1000 ether);
        vm.prank(here);
        cETH.mint{value: 1000 ether}();
        console.log("This contract's cETH balance");
        emit log_uint(cETH.balanceOf(here));
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



 
 


}