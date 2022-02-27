#!/usr/bin/python3

import pytest

#from web3 import Web3

PRICE_TAGS = (
    111111111111111111,
    333333333333333333,
    666666666666666666,
    1000000000000000000,
    3000000000000000000,
    11000000000000000000,
    111000000000000000000
)

SOME_PRICES = {
    0:  PRICE_TAGS[0],
    10: PRICE_TAGS[0],
    54: PRICE_TAGS[0],
    55: PRICE_TAGS[1],
    56: PRICE_TAGS[1],
    300: PRICE_TAGS[1],
    609: PRICE_TAGS[1],
    610: PRICE_TAGS[2],
    611: PRICE_TAGS[2],
    1720: PRICE_TAGS[2],
    1721: PRICE_TAGS[3],
    2831: PRICE_TAGS[3],
    2832: PRICE_TAGS[4],
    3386: PRICE_TAGS[4],
    3387: PRICE_TAGS[5],
    3441: PRICE_TAGS[5],
    3442: PRICE_TAGS[6],
    3446: PRICE_TAGS[6],
}

def test_prices_by_order(simulacra):
    for order, price in SOME_PRICES.items():
        assert price == simulacra.getPriceOf(order)

# TODO: price function with bissect based on points where price changes

