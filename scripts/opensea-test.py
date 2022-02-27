#!/usr/bin/python3

from brownie import TestMetadata, accounts


def main():
    deployer = accounts.load('rinkeby1')
    return TestMetadata.deploy({'from': deployer})
