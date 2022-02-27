pragma solidity ^0.7;

import "./Metadata.sol";

contract TestMetadataForSimulacra {

    uint256 public immutable size;
    ISimulacra public immutable simulacra;
    
    constructor(ISimulacra _simulacra) {
        simulacra = _simulacra;
        size = _simulacra.totalSupply();
    }
    
}
