from brownie import Lottery, config, network
from scripts.help_scripts import get_account

def deploy_lottery_contract(minimal_deposit_amount):
    owner_acc = get_account()
    lottery = Lottery.deploy(minimal_deposit_amount, {"from": owner_acc})
    return lottery


def main():
    deploy_lottery_contract(100_000)