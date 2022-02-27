#!/usr/bin/python3

from brownie.network.state import Chain
import brownie
import pytest
from web3 import Web3

@pytest.fixture(scope="module")
def popularity_indices():
    return 0x0505050505

@pytest.fixture(scope="module")
def buyer(accounts):
    return accounts[1]

@pytest.mark.parametrize("idx", range(5))
def test_initial_approval_is_zero(toy_simulacra, accounts, idx):
    assert not toy_simulacra.isApprovedForAll(accounts[0], accounts[idx])

def test_not_in_refund_mode(toy_simulacra):
    assert not toy_simulacra.isInRefundMode()

def test_commission_piece(toy_simulacra, buyer, popularity_indices):
    simulacra = toy_simulacra
    for i in range(0, simulacra.MAX_SIMULACRA()):
        assert not simulacra.artSoldOut()
        assert simulacra.totalSupply() == i
        price = simulacra.getCurrentPrice()
        tx = simulacra.commissionPieces(popularity_indices, 1, {'from': buyer, 'value': price})
        assert simulacra.balance() > 0
        assert simulacra.balanceOf(buyer) == i + 1
        assert simulacra.totalSupply() == i + 1    
    
    assert simulacra.artSoldOut()
    assert not simulacra.artWasRevealed()
    assert not simulacra.isInRefundMode()

def test_iterate_over_my_pieces(toy_simulacra, buyer):
    size_of_my_collection = toy_simulacra.balanceOf(buyer)
    for i in range(size_of_my_collection):
        assert i == toy_simulacra.tokenOfOwnerByIndex(buyer, i)

def test_premature_withdraw(toy_simulacra, accounts):
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        _ = toy_simulacra.withdraw({'from': accounts[0]})

def test_reveal(toy_simulacra, TestMetadataForSimulacra, accounts):
    mock_metadata = TestMetadataForSimulacra.deploy(toy_simulacra, {'from': accounts[0]})
    assert toy_simulacra.artSoldOut()
    assert not toy_simulacra.artWasRevealed()
    assert not toy_simulacra.isInRefundMode()
    tx = toy_simulacra.reveal(mock_metadata, {'from': accounts[0]})
    assert toy_simulacra.artWasRevealed()

def test_reveal_again(toy_simulacra, TestMetadataForSimulacra, accounts):
    mock_metadata = TestMetadataForSimulacra.deploy(toy_simulacra, {'from': accounts[0]})
    assert toy_simulacra.artWasRevealed()
    assert not toy_simulacra.isInRefundMode()
    tx = toy_simulacra.reveal(mock_metadata, {'from': accounts[0]})
    assert toy_simulacra.artWasRevealed()

    Chain().sleep(7*24*60*60)
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        tx = toy_simulacra.reveal(mock_metadata, {'from': accounts[0]})

def test_unauthorized_withdraw(toy_simulacra, accounts):
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        _ = toy_simulacra.withdraw({'from': accounts[3]})

def test_valid_withdraw(toy_simulacra, accounts):
    expected_sum = 10 * (111111111111111111 + 333333333333333333 + 666666666666666666)

    before = accounts[0].balance()
    _tx = toy_simulacra.withdraw({'from': accounts[0], 'gasPrice': 0})
    after = accounts[0].balance()
    assert after == before + expected_sum
