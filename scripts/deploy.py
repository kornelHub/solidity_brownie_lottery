from brownie import Lottery, LinkToken, network, config
from scripts.help_scripts import get_account, get_contract

def deploy_lottery_contract(minimal_deposit_amount):
    owner_acc = get_account()
    lottery = Lottery.deploy(
        minimal_deposit_amount,
        get_contract("vrf_coordinator").address,
        get_contract("link_token").address,
        config["networks"][network.show_active()]["fee"],
        config["networks"][network.show_active()]["keyhash"],
        {"from": owner_acc})
    return lottery

def deploy_link_mock():
    owner_acc = get_account()
    link_mock = LinkToken.deploy({"from": owner_acc})
    return link_mock


def main():
    deploy_lottery_contract(100_000)