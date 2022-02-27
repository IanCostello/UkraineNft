pragma solidity ^0.7;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";

interface ISimulacra {
    function totalSupply() external view returns(uint256);
}

contract Metadata is Ownable {

    uint8 public constant VERSION = 1;
    bytes2 public constant IPFS_HEADER = 0x1220;
    string public constant IPFS_PUBLIC_GATEWAY = "https://ipfs.io/ipfs/";

    ISimulacra public simulacra;
    bytes32[] public ipfsDigest;

    // FIXME: Change to internal
    uint256 internal currentSize;
    uint256 internal expectedSize;

    constructor(ISimulacra _simulacra){
        simulacra = _simulacra;
        expectedSize = _simulacra.totalSupply();
        require(expectedSize > 0, "totalSupply should be > 0");
        ipfsDigest = new bytes32[](expectedSize);
    }

    function addDigests(uint256 _from, bytes32[] calldata _batch) public onlyOwner {
        require(_from == currentSize);
        require(_batch.length + currentSize <= expectedSize);
        for(uint256 i=0; i<_batch.length; i++){
            ipfsDigest[currentSize + i] = _batch[i];
        }
        currentSize += _batch.length;
    }

    function size() public view returns(uint256){
        require(currentSize == expectedSize, "Metadata is not ready yet");
        return expectedSize;
    }

    /*
     IPFS CIDs and URIs
    */

    function ipfsCIDfromDigest(bytes32 _digest) public pure returns(string memory){
        return _toBase58(abi.encodePacked(IPFS_HEADER, _digest));
    }

    function ipfsCIDfromTokenID(uint256 _tokenID) public view returns(string memory){
        return ipfsCIDfromDigest(ipfsDigest[_tokenID]);
    }

    function ipfsTokenURI(uint256 _tokenID) external view returns(string memory){
        require(_tokenID < size(), "No metadata for this _tokenID");
        string memory ipfsCID = ipfsCIDfromTokenID(_tokenID);
        return string(abi.encodePacked(IPFS_PUBLIC_GATEWAY, ipfsCID));
    }

    /* COPIED FROM HASHMASKS CONTRACT 0x185c8078285a3de3ec9a2c203ad12853f03c462d */

    // Internal variables
    bytes internal constant _ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    // Source: verifyIPFS (https://github.com/MrChico/verifyIPFS/blob/master/contracts/verifyIPFS.sol)
    // @author Martin Lundfall (martin.lundfall@consensys.net)
    // @dev Converts hex string to base 58
    function _toBase58(bytes memory source)
        internal
        pure
        returns (string memory)
    {
        if (source.length == 0) return new string(0);
        uint8[] memory digits = new uint8[](46);
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint256 i = 0; i < source.length; ++i) {
            uint256 carry = uint8(source[i]);
            for (uint256 j = 0; j < digitlength; ++j) {
                carry += uint256(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        return string(_toAlphabet(_reverse(_truncate(digits, digitlength))));
    }

    function _truncate(uint8[] memory array, uint8 length)
        internal
        pure
        returns (uint8[] memory)
    {
        uint8[] memory output = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function _reverse(uint8[] memory input)
        internal
        pure
        returns (uint8[] memory)
    {
        uint8[] memory output = new uint8[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = input[input.length - 1 - i];
        }
        return output;
    }

    function _toAlphabet(uint8[] memory indices)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory output = new bytes(indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = _ALPHABET[indices[i]];
        }
        return output;
    }

}