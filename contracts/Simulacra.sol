pragma solidity ^0.7;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/Address.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/ReentrancyGuard.sol";

interface IMetadata {
    function size() external view returns (uint256);

    function simulacra() external view returns (address);

    function ipfsTokenURI(uint256 _tokenID)
        external
        view
        returns (string memory);
}

contract Simulacra is ERC721, Ownable, ReentrancyGuard {
    using Address for address payable;

    event Commission(
        address indexed _buyer,
        uint256 indexed _tokenID,
        uint256 _artists
    );

    event Refund(
        address indexed _tokenOwner,
        uint256 indexed _tokenID,
        uint256 _price
    );

    string constant NAME = "Toy"; // FIXME
    string constant SYMBOL = "TOY"; // FIXME

    uint256 internal constant _MAX_SIMULACRA = 3447;
    uint256 public constant MAX_ARTISTS = 44; // FIXME: 45?

    uint256 public immutable SALE_START;
    uint256 public immutable SALE_END;
    uint256 public immutable MINT_DEADLINE;

    IMetadata metadata;
    string constant EMPTY_SIMULACRA_IPFS_URL =
        "https://ipfs.io/ipfs/Qmb6tuZCf2pNwNWPgHeUCk7Y1wZt9zDTXX8uMr57cvV2Jf";
    string constant SIMULACRA_METADATA_IPFS_URL =
        "https://pastebin.com/raw/YVBNip5u"; // FIXME

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
     * Status functions
     */

    function artSoldOut() public view returns (bool) {
        return totalSupply() >= MAX_SIMULACRA();
    }

    function artWasRevealed() public view returns (bool) {
        return
            address(metadata) != address(0) && // metadata is not null ...
            metadata.simulacra() == address(this) && // ... and it's associated to this Simulacra contract
            metadata.size() == totalSupply(); // ... and its size matches our total supply.
    }

    function isInRefundMode() public view returns (bool) {
        return block.timestamp > MINT_DEADLINE && !artWasRevealed();
    }

    function MAX_SIMULACRA() public pure virtual returns (uint256) {
        return _MAX_SIMULACRA;
    }

    /*
     * Pricing functions
     */

    function getCurrentPrice() public view returns (uint256) {
        require(
            SALE_START <= block.timestamp && block.timestamp <= SALE_END,
            "Sale is closed"
        );
        require(!artSoldOut(), "No more pieces to sell");
        uint256 nextItemAvailable = totalSupply();
        return getPriceOf(nextItemAvailable);
    }

    function getPriceOf(uint256 _tokenID)
        public
        pure
        virtual
        returns (uint256)
    {
        if (_tokenID < 55) {
            return 111111111111111111; // 0.111111111111111111 ETH
        } else if (_tokenID < 610) {
            return 333333333333333333; // 0.333333333333333333 ETH
        } else if (_tokenID < 1721) {
            return 666666666666666666; // 0.666666666666666666 ETH
        } else if (_tokenID < 2832) {
            return 1000000000000000000; // 1 ETH
        } else if (_tokenID < 3387) {
            return 3000000000000000000; // 3 ETH
        } else if (_tokenID < 3442) {
            return 11000000000000000000; // 11 ETH
        } else if (_tokenID < 3447) {
            return 111000000000000000000; // 111 ETH
        } else {
            revert("Token ID must be < 3447");
        }
    }

    function remainingAtCurrentPrice() external view virtual returns (uint256) {
        uint256 piecesSold = totalSupply();
        return remainingAt(piecesSold);
    }

    function remainingAt(uint256 _piecesSold)
        internal
        view
        virtual
        returns (uint256)
    {
        uint256 nextStepAt;
        if (_piecesSold < 55) {
            nextStepAt = 55;
        } else if (_piecesSold < 610) {
            nextStepAt = 610;
        } else if (_piecesSold < 1721) {
            nextStepAt = 1721;
        } else if (_piecesSold < 2832) {
            nextStepAt = 2832;
        } else if (_piecesSold < 3387) {
            nextStepAt = 3387;
        } else if (_piecesSold < 3442) {
            nextStepAt = 3442;
        } else if (_piecesSold < 3447) {
            nextStepAt = 3447;
        } else {
            return 0;
        }
        return nextStepAt - _piecesSold;
    }

    /*
     * Transactions
     */

    function commissionPieces(uint256 _indices, uint256 _number)
        external
        payable
        nonReentrant
    {
        uint256 currentSupply = totalSupply();

        // Check sale is valid (note that call to getCurrentPrice below also makes additional checks)
        require(
            0 < _number && _number <= remainingAt(currentSupply),
            "Invalid number"
        );

        // Check the price is right
        require(msg.value == _number * getCurrentPrice(), "Invalid eth amount");

        // Check popularity indices
        require(
            uint8(_indices) <= MAX_ARTISTS,
            "1st artist index is not valid"
        );
        require(
            uint8(_indices >> 8) <= MAX_ARTISTS,
            "2nd artist index is not valid"
        );
        require(
            uint8(_indices >> 16) <= MAX_ARTISTS,
            "3rd artist index is not valid"
        );

        // Mint the NFTs
        for (uint256 i = 0; i < _number; i++) {
            uint256 tokenID = currentSupply + i;
            _safeMint(msg.sender, tokenID);
            emit Commission(msg.sender, tokenID, _indices);
        }
    }

    function reveal(address _metadata) external onlyOwner {
        require(
            block.timestamp <= MINT_DEADLINE,
            "Reveal only before the deadline"
        );
        require(
            SALE_END <= block.timestamp || artSoldOut(),
            "Sale must have ended"
        );
        metadata = IMetadata(_metadata);
        require(artWasRevealed(), "Invalid metadata contract");
    }

    /**
     * @dev Withdraw ETH from this contract. Only owner can call it.
     */
    function withdraw() external onlyOwner {
        require(artWasRevealed(), "Can't withdraw until reveal");
        uint256 balance = address(this).balance;

        msg.sender.sendValue(balance);
    }

    function getRefund(uint256 _tokenID) external nonReentrant {
        require(isInRefundMode(), "Refunds only in refund mode");
        require(
            msg.sender == ownerOf(_tokenID),
            "Only token owner gets a refund"
        );

        uint256 price = getPriceOf(_tokenID);
        _burn(_tokenID);

        msg.sender.sendValue(price);
        emit Refund(msg.sender, _tokenID, price);
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

        if (artWasRevealed()) {
            return metadata.ipfsTokenURI(_tokenID);
        } else {
            return EMPTY_SIMULACRA_IPFS_URL; // FIXME: Maybe revert instead?
        }
    }

    function contractURI() external view returns (string memory) {
        return SIMULACRA_METADATA_IPFS_URL;
    }
}
