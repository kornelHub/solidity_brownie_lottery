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
    event WithdrawnFromLottery(address addressToWithdraw, uint256 amount);

    constructor(uint256 _minimalDeposit) Ownable() {
        minimalDeposit = _minimalDeposit;
        usersInLottery = 0;
        currentState = LotteryState.OPEN;
    }

    modifier isLotteryOpen() {
        require(currentState == LotteryState.OPEN,
            "This action is allowed only when lottery is open!");
        _;
    }

    modifier isValueGreaterThanMinimal() {
        require(msg.value >= minimalDeposit,
            "Amount to low. Use minimalDeposit() to see minimum amount!");
        _;
    }

    modifier haveUserDepositedFunds() {
        require(addressToDepositedValue[msg.sender] > 0,
            "You are not in lottery, no funds deposited!");
        _;
    }

    function enterLottery() public payable isLotteryOpen isValueGreaterThanMinimal {
        addressToDepositedValue[msg.sender] += msg.value;
        usersInLottery += 1;
        emit FundsDeposited(msg.sender, msg.value, addressToDepositedValue[msg.sender]);
    }

    function quiteLottery() public isLotteryOpen haveUserDepositedFunds{
        uint256 amount_to_withdraw = addressToDepositedValue[msg.sender];
        payable(msg.sender).transfer(amount_to_withdraw);
        usersInLottery -= 1;
        addressToDepositedValue[msg.sender] = 0;
        emit WithdrawnFromLottery(msg.sender, amount_to_withdraw);
    }

    function changeMinimalDepositAmount(uint256 _newValue) public onlyOwner {
        minimalDeposit = _newValue;
    }
}