// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable{
    uint256 public minimalDeposit;
    mapping(address => uint256) public addressToDepositedValue;
    uint256 public usersInLottery;
    enum LotteryState {OPEN, CLOSED, CHOOSING_WINNER}
    LotteryState public currentState;

    event FundsDeposited(address depositor, uint256 amount, uint256 totalBalanceOfDepositor);

    constructor(uint256 _minimalDeposit) Ownable() {
        minimalDeposit = _minimalDeposit;
        usersInLottery = 0;
        currentState = LotteryState.OPEN;
    }

    modifier isLotteryOpen() {
        require(currentState == LotteryState.OPEN, "Can not enter un open lottery!");
        _;
    }

    function enterLottery() public payable isLotteryOpen {
        require(msg.value >= minimalDeposit, "Amount to low. Use minimalDeposit() to see minimum amount!");
        addressToDepositedValue[msg.sender] += msg.value;
        usersInLottery += 1;
        emit FundsDeposited(msg.sender, msg.value, addressToDepositedValue[msg.sender]);
    }

    function changeMinimalDepositAmount(uint256 _newValue) public onlyOwner {
        minimalDeposit = _newValue;
    }
}