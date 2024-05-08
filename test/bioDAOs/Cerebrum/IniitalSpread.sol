// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./ERC20Mintable.sol";
import "../../UniswapV3Pool.Utils.t.sol";

import "../../../src/interfaces/IUniswapV3Pool.sol";
import "../../../src/lib/LiquidityMath.sol";
import "../../../src/lib/TickMath.sol";
import "../../../src/UniswapV3Factory.sol";
import "../../../src/UniswapV3Pool.sol";

import "../../../src/lib/LiquidityMath.sol";
import "../../../src/UniswapV3NFTManager.sol";


contract UniswapV3PoolSwapsTest is Test, UniswapV3PoolUtils {
    ERC20Mintable WETH;
    ERC20Mintable USDC;
    ERC20Mintable NEURON;
    UniswapV3Factory factory;
    UniswapV3Pool pool;

    bool transferInMintCallback = true;
    bool transferInSwapCallback = true;
    bytes extra;

    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    uint256 AUCTION_PRICE_WEI = 76056130000;
    

    function setUp() public {

        USDC = new ERC20Mintable("USDC", "USDC", 18);
        WETH = new ERC20Mintable("Ether", "ETH", 18);
        NEURON = ERC20Mintable(0xab814ce69e15f6b9660a3b184c0b0c97b9394a6b);
        factory = new UniswapV3Factory();

        extra = encodeExtra(address(WETH), address(NEURON), address(this));
    }


    function test_position_creation() public {
        vm.createSelectFork(MAINNET_RPC_URL, 16_678_635);

        uint256 liqStartPrice = 76056130000 * 11 / 10;
        
        uint256 exampleSize = 76056130000 * 1 ether;

        // add position below

    }
}