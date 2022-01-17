// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is Ownable, VRFConsumerBase{
    bytes32 public keyHash;
    uint256 public fee;
    uint256 public minimalDeposit;
    mapping(address => uint256) public addressToDepositedValue;
    address payable[] public players;
    enum LotteryState {OPEN, CHOOSING_WINNER}
    LotteryState public currentState;

    event FundsDeposited(address depositor, uint256 amount, uint256 totalBalanceOfDepositor);
    event WithdrawnFromLottery(address addressToWithdraw, uint256 amount);
    event RequestedRandomness(bytes32 requestId);

    constructor(
        uint256 _minimalDeposit,
        address _vrfCoordinator,
        address _linkToken,
        uint256 _fee,
        bytes32 _keyHash
    ) Ownable() VRFConsumerBase(_vrfCoordinator, _linkToken) {
        fee = _fee;
        keyHash = _keyHash;
        minimalDeposit = _minimalDeposit;
        currentState = LotteryState.OPEN;
    }

    modifier isLotteryOpen() {
        require(currentState == LotteryState.OPEN, "This action is allowed only when lottery is open!");
        _;
    }

    modifier isValueGreaterThanMinimal() {
        require(msg.value >= minimalDeposit, "Amount to low. Use minimalDeposit() to see minimum amount!");
        _;
    }

    modifier haveUserDepositedFunds() {
        require(addressToDepositedValue[msg.sender] > 0, "You are not in lottery, no funds deposited!");
        _;
    }

    modifier atLeastTwoUsersInLottery() {
        require(getPlayersCount() > 1, "There is not enough users to calculate users!");
        _;
    }

    function enterLottery() public payable isLotteryOpen isValueGreaterThanMinimal {
        if (addressToDepositedValue[msg.sender] == 0) {
            players.push(payable(msg.sender));
        }
        addressToDepositedValue[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value, addressToDepositedValue[msg.sender]);
    }

    function quiteLottery() public isLotteryOpen haveUserDepositedFunds {
        uint256 amount_to_withdraw = addressToDepositedValue[msg.sender];
        payable(msg.sender).transfer(amount_to_withdraw);
        addressToDepositedValue[msg.sender] = 0;
        removeByValue(msg.sender);
        emit WithdrawnFromLottery(msg.sender, amount_to_withdraw);
    }

    function chooseWinner() public isLotteryOpen onlyOwner atLeastTwoUsersInLottery {
        currentState = LotteryState.CHOOSING_WINNER;
        bytes32 requestId = requestRandomness(keyHash, fee);
        emit RequestedRandomness(requestId);
    }

    function changeMinimalDepositAmount(uint256 _newValue) public onlyOwner {
        minimalDeposit = _newValue;
    }

    function getPlayersCount() public view returns (uint256) {
        return players.length;
    }

    function find(address value) internal returns(uint) {
        uint i = 0;
        while (players[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(address value) internal {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint index) internal {
        delete players[index];
        for (uint i = index; i<players.length-1; i++) {
            players[i] = players[i+1];
        }
        players.pop();
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(currentState == LotteryState.CHOOSING_WINNER);
        require(_randomness > 0);
        //add logic to choosing winner. Need to think about this.
    }
}