#!/usr/bin/python3

import os

import brownie
import pytest
from web3 import Web3


BATCH_SIZE = 20
NUMBER_OF_BATCHES = 5
EXPECTED_SIZE = BATCH_SIZE * NUMBER_OF_BATCHES

@pytest.fixture(scope="module")
def simulacra(TestSimulacraForMetadata, accounts):
    return TestSimulacraForMetadata.deploy(EXPECTED_SIZE, {'from': accounts[0]})

@pytest.fixture(scope="module")
def metadata(TestMetadataExposed, simulacra, accounts):
    return TestMetadataExposed.deploy(simulacra, {'from': accounts[0]})


cid_and_digests = {
    'QmPZZYeAJKpSFYLzG93VXzMumXyGXvyf3aC6XPWf9nm698': '122A663F6251F071AE6A3A5343EF0D79E2D63FE3F2501D5B1DF103765758373B',
    'QmUKuS1PPEv32rrs27gB7aUrqZnCt3pkhU2TZU8Qm3xDtt': '58F52FFCD363F65C17B03070C86F77CE4558233E20BDA2312DE58A91B7970DE9'
}

def test_ipfs_cid_from_digest(metadata):
    for expected_cid, digest in cid_and_digests.items():
        digest = bytes.fromhex(digest)
        cid = metadata.ipfsCIDfromDigest(digest)
        assert cid == expected_cid

def test_init_metadata(metadata, accounts):
    assert metadata.expectedSizeExposed() == EXPECTED_SIZE
    assert metadata.currentSizeExposed() == 0
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        _ = metadata.size()

def test_add_digest(metadata, accounts):
    for i in range(NUMBER_OF_BATCHES):
        data = [os.urandom(32) for _ in range(BATCH_SIZE)]
        assert len(data) == BATCH_SIZE

        current = i * BATCH_SIZE
        assert metadata.currentSizeExposed() == current

        with pytest.raises(brownie.exceptions.VirtualMachineError):
            _ = metadata.size()
        
        tx = metadata.addDigests(current, data, {'from': accounts[0]})
        for j, x in enumerate(data):
            assert bytes(metadata.ipfsDigest(current + j)) == x
        gas = tx.gas_used - 21000
        print(gas, round(gas/BATCH_SIZE, 2))
    
    assert metadata.size() == EXPECTED_SIZE



        

