pragma solidity ^0.7;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/Address.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ERC20 {
    function size() external view returns (uint256);

    function simulacra() external view returns (address);

    function ipfsTokenURI(uint256 _tokenID)
        external
        view
        returns (string memory);
}

contract Simulacra is ERC721, Ownable, ReentrancyGuard {
    using Address for address payable;

    string constant NAME = "Ukraine";
    string constant SYMBOL = "UKR";

    string constant IPFS_BASE_LINK = "";
    uint256 public constant PUBLIC_SALE_PRICE = 0.05 ether;
    uint256 public constant MAX_TOKEN_COUNT = 10000;
    uint256 public totalTokenCount = 0;

    constructor(
        uint256 _saleStartTimestamp,
        uint8 _saleDurationInDays,
        uint8 _failsafeDurationInDays
    ) ERC721(NAME, SYMBOL) {
        require(
            block.timestamp <= _saleStartTimestamp &&
                _saleDurationInDays > 0 &&
                _failsafeDurationInDays > 0,
            "Sale parameters are not valid"
        );

        SALE_START = _saleStartTimestamp;
        uint256 sale_end = _saleStartTimestamp + (_saleDurationInDays * 1 days);
        SALE_END = sale_end;
        MINT_DEADLINE = sale_end + (_failsafeDurationInDays * 1 days);
    }

    /*
     *
     */
    function mint() external payable nonReentrant {
        require(PUBLIC_SALE_PRICE >= msg.value, "Incorrect ETH value sent");
        _safeMint();
    }

    /*
     * Status functions
     */
    function artSoldOut() public view returns (bool) {
        return totalSupply() >= MAX_TOKEN_COUNT;
    }

    function getCurrentPrice() public view returns (uint256) {
        return 0.05;
    }

    function totalSupply() external view returns (uint256) {
        return totalTokenCount;
    }

    /**
     * @dev Withdraw ETH from this contract. Only owner can call it.
     */
    function withdraw() external onlyOwner {
        require(artWasRevealed(), "Can't withdraw until reveal");
        uint256 balance = address(this).balance;

        msg.sender.sendValue(balance);
    }

    function withdrawTokens(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    /*
     * Metadata
     */
    function tokenURI(uint256 _tokenID)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenID), "_tokenID doesn't exist");

        return
            bytes(baseImageURI).length > 0
                ? string(
                    abi.encodePacked(IPFS_BASE_LINK, Strings.toString(_tokenID))
                )
                : "";
    }

    function contractURI() external view returns (string memory) {
        return IPFS_BASE_LINK;
    }
}
