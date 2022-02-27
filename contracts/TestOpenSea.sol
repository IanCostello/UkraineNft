pragma solidity ^0.7;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC721/ERC721.sol";


contract TestOpenSea is ERC721 {

    string constant NAME = "Test Simulacra";  // FIXME
    string constant SYMBOL = "TEST";  // FIXME

    constructor() ERC721(NAME, SYMBOL) {
        _safeMint(msg.sender, 1234);
    }

    function mint(uint256 _tokenID) public {
        _safeMint(msg.sender, _tokenID);
    }

    function tokenURI(uint256 _tokenID) public view override returns(string memory){
        return "https://pastebin.com/raw/VmKC9Apg";
    }

    function contractURI() public view returns (string memory) {
        return "https://pastebin.com/raw/YVBNip5u";
    }

}
