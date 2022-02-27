pragma solidity ^0.7;

import "./Simulacra.sol";


contract TestSimulacra is Simulacra {

    uint256 constant TEST_MAX_SIMULACRA = 30;

    constructor(uint256 _saleStartTimestamp, uint8 _saleDurationInDays, uint8 _failsafeDurationInDays)
        Simulacra(_saleStartTimestamp, _saleDurationInDays, _failsafeDurationInDays) {
    }

    function MAX_SIMULACRA() public override pure returns(uint256){
        return TEST_MAX_SIMULACRA;
    }

    function getPriceOf(uint256 _index) public override pure returns(uint256){       
        if (_index < 10){
            return 111111111111111111;  // 0.111111111111111111 ETH
        } else if (_index < 20) {
            return 333333333333333333;  // 0.333333333333333333 ETH
        } else {
            return 666666666666666666;  // 0.666666666666666666 ETH
        }
    }

    function remainingAtCurrentPrice() public override view returns(uint256){
        uint256 piecesSold = totalSupply();
        uint256 nextStepAt;
        if (piecesSold < 10){
            nextStepAt = 10;
        } else if (piecesSold < 20) {
            nextStepAt = 20;
        } else if (piecesSold < 30) {
            nextStepAt = 30;
        } else {
            return 0;
        }
        return nextStepAt - piecesSold;
    }
    
}
