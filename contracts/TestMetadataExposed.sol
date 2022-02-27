pragma solidity ^0.7;

import "./Metadata.sol";


contract TestMetadataExposed is Metadata {

    constructor(ISimulacra _address) Metadata(_address) {}

    function currentSizeExposed() public view returns(uint256){
        return currentSize;
    }

    function expectedSizeExposed() public view returns(uint256){
        return expectedSize;
    }
}
