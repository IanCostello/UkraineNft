#!/usr/bin/python3

import pytest
from web3 import Web3

@pytest.fixture(scope="module")
def popularity_indices():
    return 0x0505050505

@pytest.fixture(scope="module")
def buyer(accounts):
    return accounts[1]

def test_commission_one_piece(simulacra, buyer, popularity_indices):
    assert not simulacra.artSoldOut()
    assert simulacra.totalSupply() == 0
    price = simulacra.getCurrentPrice()
    tx = simulacra.commissionPieces(popularity_indices, 1, {'from': buyer, 'value': price})
    assert simulacra.balance() > 0
    assert simulacra.balanceOf(buyer) == 1
    assert simulacra.totalSupply() == 1    

def test_commission_multiple_piece(simulacra, buyer, popularity_indices):
    expected_supply = simulacra.totalSupply()
    remaining = simulacra.remainingAtCurrentPrice()
    while remaining:
        assert not simulacra.artSoldOut()
        price = simulacra.getCurrentPrice()
        amount = min(remaining, 56)  # Approximate limit amount with test block gas limit
        tx = simulacra.commissionPieces(popularity_indices, amount, {'from': buyer, 'value': price * amount})
        assert simulacra.balance() > 0
        assert simulacra.balanceOf(buyer) == expected_supply + amount
        assert simulacra.totalSupply() == expected_supply + amount
        expected_supply = simulacra.totalSupply()
        remaining = simulacra.remainingAtCurrentPrice()

    assert simulacra.artSoldOut()
    assert not simulacra.artWasRevealed()
    assert not simulacra.isInRefundMode()
    