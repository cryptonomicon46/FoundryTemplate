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
      ICOMP comp = ICOMP(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    CETH cETH = CETH(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    CERC20 cWBTC = CERC20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IComptroller comptroller = IComptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
     address here = address(this);
     address[] cTokens = new address[](2);
    uint[]  results = new uint[](2);



    function setUp() public {
    console.log("This contract's address = %s", here);
    vm.createSelectFork("mainnet",17_033_152);
     vm.label(address(cDAI),"cDAI");
     vm.label(address(dai),"dai");
     vm.label(address(cETH),"cETH");
     vm.label(address(comptroller),"comptroller");
     vm.label(address(this),"here");

    
    cTokens[0] = address(cETH);
    cTokens[1] = address(cDAI);
    console.log("Entering cETH and cDAI markets..");

    results = comptroller.enterMarkets(cTokens);


    }
    
    /**@notice testMint_cDAI achieves the following
    - first deal this contract 4000 dai 
     */

    function testMint_cDAI() public {
    console.log("Dealing this contract 4000 DAI");
    deal(address(dai),here,4000 ether);
    emit log_named_uint("DAI balance of this contract",dai.balanceOf(here));
    dai.approve(address(cDAI),100 ether);
    console.log("Minting some Compound Dai for this contract");
    assert(cDAI.mint(100 ether)==0);
    emit log_named_uint("cDAI underlying balance of this contract:",cDAI.balanceOfUnderlying(here)/1e18);
    emit log_named_uint("cDAI balance of this contract:",cDAI.balanceOf(here));
    emit log_named_decimal_uint("cDAI exchange rate:",cDAI.exchangeRateCurrent(),(18-8+18));
    emit log_named_uint("cDAI cash reserves:",cDAI.getCash());
    emit log_named_uint("cDAI total borrow in the market:",cDAI.totalBorrowsCurrent());

    }

    function testExchangeRate_DAI() public  {
        console.log("Starting testExchangeRate_DAI()...");
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
        uint cDAIBalCalc = 10_000 ether/calcExchangeRate;
        emit log_named_decimal_uint("Calculated cDAI amount before minting:", cDAIBalCalc,8);
        emit log_named_decimal_uint("Current Exchange Rate:",cDAI.exchangeRateCurrent(),(18-8+18));

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDAI),10_000 ether);
        assert(cDAI.mint(10_000 ether)==0);
        emit log_named_decimal_uint("cDAI Balance of contract after mint:", cDAI.balanceOf(here),8);
        emit log_named_decimal_uint("Dai underlying balance after mint:", cDAI.balanceOfUnderlying(here),18);
        uint cDAIBalActual = cDAI.balanceOf(here);
        assertLt((cDAIBalCalc-cDAIBalActual),0.01 ether);
        uint skipBlockTimeStamp = 100_000_000;
        console.log("Skipping blocktimestamp by %s seconds", skipBlockTimeStamp);
        skip(skipBlockTimeStamp);
        emit log_named_decimal_uint("Exchange rate after skip:",cDAI.exchangeRateCurrent(),(18-8+18));
        emit log_named_decimal_uint("cDAI totalReserves after skip",cDAI.totalReserves(),8);




    }


  function testBorrow_DAI() public  {
        console.log("Entering testBorrow_DAI test...");

        deal(address(dai),here,10_000 ether);
        console.log("Dealing this contract %s DAI.", dai.balanceOf(here)/1e18);
        dai.approve(address(cDAI),10_000 ether);
        assert(cDAI.mint(10_000 ether)==0);
        emit log_named_uint("Current cDAI borrow rate", cDAI.borrowRatePerBlock());

        emit log_named_decimal_uint("cDAI borrow balance of here before borrowing :",cDAI.borrowBalanceCurrent(here),18);

        assert(cDAI.borrow(1000 ether) ==0);
        uint finalTotalBorrows = cDAI.totalBorrowsCurrent();
        emit log_named_decimal_uint("TotalBorrows After borrow:",cDAI.totalBorrowsCurrent(),18);
        uint256 cDAI_BB_1 = cDAI.borrowBalanceCurrent(here);
        emit log_named_decimal_uint("cDAI current borrow balance of this contract:",cDAI_BB_1,18);
        emit log_named_decimal_uint("Borrow rate per block",cDAI.borrowRatePerBlock(),18);
        emit log_named_decimal_uint("Reserve Factor",cDAI.reserveFactorMantissa(),18);

        vm.roll(block.number + 1);
        uint256 cDAI_BB_2 = cDAI.borrowBalanceCurrent(here);
        uint256 cDAI_delta = cDAI_BB_2- cDAI_BB_1;
        emit log_named_decimal_uint("cDAI current borrow balance after advancing blocks:",cDAI_BB_2,18);
        emit log_named_uint("Delta increase in the borrow balance in Gwei=",cDAI_delta/1e9 );
        assertGt(cDAI_delta, 0 ether);



    }

    function testFail_BorrowDai() public {

        emit log_uint(cDAI.borrowBalanceCurrent(here));

        assert(cDAI.borrow(1000 ether) ==0);

    }

/***@notice  Supply ETH to the cETH contract, check the cToken balances and redeem. 
 */    function testSupply_ETH() public{
     console.log("Supplying liquidity into the cETH contract");
        vm.deal(here, 1000 ether); 
        uint256 initialBalETH = address(this).balance;
        emit log_named_uint("Supplied ETH liquidity", 1000 ether);
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
       assertEq(calculatedMinted,actualMinted_cETH);
       vm.roll(block.number+50_000);
       uint256 currentBalanceMinted  = cETH.balanceOf(here);
       assertEq(cETH.redeem(currentBalanceMinted),0);
       assertEq(cETH.balanceOf(here),0);
       uint256 finalBalETH  = address(this).balance;
        assertGt(finalBalETH,initialBalETH);
      emit log_named_decimal_uint("ETH redeemed after advancing blocks", finalBalETH,18);

    }

    function testEnterMarkets_ALL() public {
        address[] memory marketsEntered = new address[](2);
        marketsEntered = comptroller.getAssetsIn(here);
        assert(results[0]==0);
        assert(results[1]==0);

        assertEq(marketsEntered[0],address(cETH));
        assertEq(marketsEntered[1],address(cDAI));
    }

    function testExitMarkets_ALL() public {
        uint256[] memory marketsExited = new uint256[](2);
        marketsExited[0] = comptroller.exitMarket(cTokens[0]);
        marketsExited[1] = comptroller.exitMarket(cTokens[1]);
        assert(marketsExited[0]==0);
        assert(marketsExited[1]==0);
    }
    function testEnterMarket_ETH() public {
        console.log("testEnterMarket_ETH starting....");
        bool checkMembership_0 = comptroller.checkMembership(here,cTokens[0]);
        console.log("Checking membership for cETH market");
        assertTrue(checkMembership_0);

        (,uint256 collateralFactor,) = comptroller.markets(cTokens[0]);
        emit log_named_decimal_uint("CollateralFactor before supplying ETH:", collateralFactor,18);

        (,uint256 accountLiquidity,) = comptroller.getAccountLiquidity(here);
        emit log_named_decimal_uint("Account liquidity in $USD (before supplying ETH)", accountLiquidity,18);

        emit log_named_decimal_uint("cETH Exchange Rate", cETH.exchangeRateCurrent(),(18-8+18));
        uint expectedMinted = (1e18* 1000 ether)/cETH.exchangeRateCurrent();
        emit log_named_decimal_uint("Expected cETH minted tokens:", expectedMinted,8);
        vm.deal(here, 1_000 ether);
        cETH.mint{value: 1_000 ether}();
        results = comptroller.enterMarkets(cTokens);
        emit log_named_decimal_uint("This contract's cETH balance after supplying ETH:", cETH.balanceOf(here),8);


        (, collateralFactor,) = comptroller.markets(cTokens[0]);
        emit log_named_decimal_uint("CollateralFactor after supplying ETH:", collateralFactor,18);

        (, accountLiquidity,) = comptroller.getAccountLiquidity(here);
        emit log_named_decimal_uint("Account liquidity in $USD (after supplying ETH)", accountLiquidity,18);

        emit log_named_decimal_uint("cEth balance of here", cETH.balanceOf(here),8);
        console.log("Borrowing cDAI tokens..");

        uint256 closeFactor = comptroller.closeFactorMantissa();
        emit log_named_decimal_uint("Close factor before borrowing DAI", closeFactor,18);

        assertEq(cDAI.borrow(1000 ether),0);

                 closeFactor = comptroller.closeFactorMantissa();
        emit log_named_decimal_uint("Close factor after borrowing DAI", closeFactor,18);
        emit log_named_decimal_uint("Collateral factor of cDAI", collateralFactor,18);

        console.log("Advancing blocks...");
        uint256 borrowBalanceDai = dai.balanceOf(here);
        emit log_named_decimal_uint("dai balance of this contract", dai.balanceOf(here),18);
        emit log_named_decimal_uint("cDAI borrow balance of this contract", cDAI.borrowBalanceCurrent(here),18);

        dai.approve(address(cDAI), borrowBalanceDai);
        assertEq(cDAI.repayBorrow(borrowBalanceDai),0);
        assertEq(cDAI.borrowBalanceCurrent(here),0);


         closeFactor = comptroller.closeFactorMantissa();
        emit log_named_decimal_uint("Close factor after repaying DAI", closeFactor,18);


    }

   function testSupplyETH_ClaimComp() public {
        emit log_named_uint ("Comp totalSupply", comp.totalSupply());
        uint256 initialCompBal = comp.balanceOf(here);

        address[] memory tokens = new address[](1);
        tokens[0] = address(cETH);
        vm.deal(here, 1_000 ether);

        deal(address(dai),here,10_000 ether);
        dai.approve(address(cDAI),10_000 ether);
        assert(cDAI.mint(10_000 ether)==0);
        // comptroller.claimComp(here);
        results = comptroller.enterMarkets(cTokens);

        comptroller.claimComp(here, cTokens);

        emit log_named_decimal_uint("Comp balance before supplying liquidity", comp.balanceOf(here),18);
        // cETH.mint{value: 1_000 ether}();
        // comptroller.claimComp_1(here, tokens);

        // emit log_named_decimal_uint("Comp balance after supplying liquidity", comp.balanceOf(here),18);
        // cETH.borrow(500 ether);
        vm.roll(block.number + 1_000_000);
        comptroller.claimComp(here, cTokens);
        uint256 finalCompBal = comp.balanceOf(here);
        assertGt(finalCompBal, initialCompBal);

        emit log_named_decimal_uint("Comp balance after time advance", comp.balanceOf(here),18);
        


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