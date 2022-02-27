#!/usr/bin/python3

from brownie.network.state import Chain
import pytest


# @pytest.fixture(scope="function", autouse=True)
# def isolate(fn_isolation):
#     # perform a chain rewind after completing each test, to ensure proper isolation
#     # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
#     pass


@pytest.fixture(scope="module")
def simulacra(Simulacra, accounts):
    block_timestamp = Chain().time()
    return Simulacra.deploy(block_timestamp, 1, 2, {'from': accounts[0]})

@pytest.fixture(scope="module")
def toy_simulacra(TestSimulacra, accounts):
    block_timestamp = Chain().time()
    return TestSimulacra.deploy(block_timestamp, 1, 2, {'from': accounts[0]})

@pytest.fixture(scope="module")
def toy_depot(Depot, accounts):
    return Depot.deploy(30, {'from': accounts[0]})
