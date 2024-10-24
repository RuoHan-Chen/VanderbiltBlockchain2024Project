// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    IERC721 public nft;
    uint256 public nftId;

    address payable public seller;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        require(!started, "Auction has already started");
        require(msg.sender == seller, "Only the seller can start the auction");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;

        emit Start();
    }

    function bid() external payable {
        require(started, "Auction has not started");
        require(!ended, "Auction has already ended");
        require(msg.value > highestBid, "New bid must be higher than the current highest bid");

        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    function end() external {
        require(started, "Auction has not started");
        require(!ended, "Auction has already ended");
        require(msg.sender == seller, "Only the seller can start the auction");

        ended = true;

        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}
