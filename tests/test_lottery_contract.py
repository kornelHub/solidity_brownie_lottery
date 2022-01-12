from scripts.deploy import deploy_lottery_contract
from scripts.help_scripts import get_account
from web3 import Web3
import pytest
from brownie import reverts

@pytest.fixture
def default_minimal_deposit_amount():
    return 100_000

@pytest.fixture
def lottery(default_minimal_deposit_amount):
    return deploy_lottery_contract(default_minimal_deposit_amount)

@pytest.fixture
def owner_acc():
    return get_account()

@pytest.fixture
def acc1():
    return get_account(index=1)

@pytest.fixture
def acc2():
    return get_account(index=2)

@pytest.fixture
def acc3():
    return get_account(index=3)


def test_initial_values_pass(lottery, owner_acc, default_minimal_deposit_amount):
    assert lottery.minimalDeposit() == default_minimal_deposit_amount
    assert lottery.owner() == owner_acc
    assert lottery.currentState() == 0
    assert lottery.usersInLottery() == 0

def test_change_minimal_deposit_amount_pass(lottery, owner_acc, default_minimal_deposit_amount):
    new_minimal_deposit = 420_2137_420
    assert lottery.minimalDeposit() == default_minimal_deposit_amount
    change_tx = lottery.changeMinimalDepositAmount(new_minimal_deposit, {"from": owner_acc})
    change_tx.wait(1)
    assert lottery.minimalDeposit() == new_minimal_deposit

def test_change_minimal_deposit_amount_not_owner_fail(lottery, acc1, default_minimal_deposit_amount):
    new_minimal_deposit = 420_2137_420
    assert lottery.minimalDeposit() == default_minimal_deposit_amount
    with reverts("Ownable: caller is not the owner"):
        lottery.changeMinimalDepositAmount(new_minimal_deposit, {"from": acc1})
    assert lottery.minimalDeposit() == default_minimal_deposit_amount

def test_enter_lottery(lottery, acc1, default_minimal_deposit_amount):
    starting_balance_of_lottery_sc = lottery.balance()
    starting_balance_of_lottery_user = lottery.addressToDepositedValue(acc1)
    starting_users_in_lottery = lottery.usersInLottery()
    amount_to_deposit = default_minimal_deposit_amount*2
    enter_tx = lottery.enterLottery({"from": acc1, "value": amount_to_deposit})
    enter_tx.wait(1)

    assert lottery.balance() == amount_to_deposit + starting_balance_of_lottery_sc
    assert lottery.addressToDepositedValue(acc1) == amount_to_deposit + starting_balance_of_lottery_user
    assert lottery.usersInLottery() == starting_users_in_lottery + 1
    assert enter_tx.events['FundsDeposited']['depositor'] == acc1
    assert enter_tx.events['FundsDeposited']['amount'] == amount_to_deposit
    assert enter_tx.events['FundsDeposited']['totalBalanceOfDepositor'] \
           == starting_balance_of_lottery_user + amount_to_deposit

    starting_balance_of_lottery_sc = lottery.balance()
    starting_balance_of_lottery_user = lottery.addressToDepositedValue(acc1)
    starting_users_in_lottery = lottery.usersInLottery()
    amount_to_deposit = default_minimal_deposit_amount * 2
    enter_tx = lottery.enterLottery({"from": acc1, "value": amount_to_deposit})
    enter_tx.wait(1)

    assert lottery.balance() == amount_to_deposit + starting_balance_of_lottery_sc
    assert lottery.addressToDepositedValue(acc1) == amount_to_deposit + starting_balance_of_lottery_user
    assert lottery.usersInLottery() == starting_users_in_lottery + 1
    assert enter_tx.events['FundsDeposited']['depositor'] == acc1
    assert enter_tx.events['FundsDeposited']['amount'] == amount_to_deposit
    assert enter_tx.events['FundsDeposited']['totalBalanceOfDepositor'] \
           == starting_balance_of_lottery_user + amount_to_deposit

def test_enter_lottery_value_below_minimal(lottery, acc1, default_minimal_deposit_amount):
    starting_balance_of_lottery_sc = lottery.balance()
    starting_balance_of_lottery_user = lottery.addressToDepositedValue(acc1)
    starting_users_in_lottery = lottery.usersInLottery()
    with reverts("Amount to low. Use minimalDeposit() to see minimum amount!"):
        lottery.enterLottery({"from": acc1, "value": default_minimal_deposit_amount/2})
    assert lottery.balance() == starting_balance_of_lottery_sc
    assert lottery.addressToDepositedValue(acc1) == starting_balance_of_lottery_user
    assert lottery.usersInLottery() == starting_users_in_lottery