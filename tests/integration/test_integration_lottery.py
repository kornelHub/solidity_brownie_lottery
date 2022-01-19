from scripts.deploy import deploy_lottery_contract
from scripts.help_scripts import get_account, get_contract, fund_with_link
from web3 import Web3
import pytest

@pytest.fixture
def default_minimal_deposit_amount():
    return Web3.toWei(0.001,"ether")

@pytest.fixture
def lottery(default_minimal_deposit_amount):
    return deploy_lottery_contract(default_minimal_deposit_amount)

@pytest.fixture
def owner_acc():
    return get_account(name="acc1")

@pytest.fixture
def acc1():
    return get_account(name="acc2")

@pytest.fixture
def acc2():
    return get_account(name="acc3")

@pytest.mark.require_network("rinkeby")
def test_vrf_coordiator_connection_pass(lottery, owner_acc, acc1, acc2, default_minimal_deposit_amount):
    enter_tx1 = lottery.enterLottery({"from": acc1, "value": default_minimal_deposit_amount})
    enter_tx1.wait(1)
    enter_tx2 = lottery.enterLottery({"from": acc2, "value": default_minimal_deposit_amount})
    enter_tx2.wait(1)

    fund_with_link(lottery)
    close_tx = lottery.chooseWinner({"from": owner_acc})
    close_tx.wait(3)

    assert lottery.addressToDepositedValue(acc1) == 0
    assert lottery.addressToDepositedValue(acc2) == 0
    assert lottery.getPlayersCount() == 0