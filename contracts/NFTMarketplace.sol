// Your code here
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Internal import for NFT OpenZeppelin contract
import "@openzeppelin/contracts/utils/Counters.sol"; // keeps track of how many items are being created and sold
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // for the ERC721 token
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import the console library from Hardhat
import "hardhat/console.sol";

// NFTMarketplace contract inherits from the ERC721URIStorage contract
contract NFTMarketplace is ERC721URIStorage {
    // import the Counters library from OpenZeppelin
    using Counters for Counters.Counter;

    // counter to keep track of the number of items created and sold
    // these are global state variables
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 listingPrice = 0.0015 ether;
    address payable owner;

    // mapping to store the market item data
    mapping(uint256 => MarketItem) private idMarketItem;

    // struct to store the market item data
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // event to emit when a new item is created
    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // function modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can change listing price");
        _;
    }

    // create a new NFT from the constructor function ERC721
    constructor() ERC721("NFT Metaverse Token", "MYNFT") {
        owner == payable(msg.sender);
    }

    // update listing price
    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    // get listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Function to create a NFT Token function
    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint256) {
        // increment the token id
        _tokenIds.increment();

        // get the new token id
        uint256 newTokenId = _tokenIds.current();

        // mint the new token
        _mint(msg.sender, newTokenId);

        // set the token URI
        _setTokenURI(newTokenId, tokenURI);

        // create a market item
        createMarketItem(newTokenId, price);

        // return the new token id
        return newTokenId;
    }

    // Function to create a market item
    function createMarketItem(uint256 tokenId, uint256 price) private {
        // check if the price is greater than 0
        require(price > 0, "Price must be at least 1 wei");
        // check if the token price is equal to the listing price
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        // store the market item data in the mapping
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        // transfer the ownership of the token to the contract
        _transfer(msg.sender, address(this), tokenId);

        // emit the event when a new item is created
        emit idMarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    // Function for NFT Token resale
    function resellToken(uint256 tokenId, uint256 price) public payable {
        // check to see that the owner is the one calling the function
        require(
            idMarketItem[tokenId].owner == msg.sender,
            "You are not the owner of this token"
        );

        // check if the price is the same as the listing price
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        // check if the token is not sold
        idMarketItem[tokenId].sold = false;

        // update the price of the token
        idMarketItem[tokenId].price = price;

        // transfer the ownership of the token to the contract
        idMarketItem[tokenId].seller = payable(msg.sender);

        // change the owner of the token to the contract
        idMarketItem[tokenId].owner = payable(address(this));

        // Decrease the number of items in the counter state variable for items sold
        _itemsSold.decrement();

        // transfer
        _transfer(msg.sender, address(this), tokenId);
    }

    // Function to create Market Sale
    function createMarketSale(uint256 tokenId) public payable {
        // get the price of the token
        uint256 price = idMarketItem[tokenId].price;

        // check the price of the token is submitted
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        // check the owner is now the payable to the buyer
        idMarketItem[tokenId].owner = payable(msg.sender);

        // check the token is sold
        idMarketItem[tokenId].sold = true;

        // transfer the ownership of the token to the buyer
        idMarketItem[tokenId].owner = payable(address(0));

        // increment the number of items sold
        _itemsSold.increment();

        // transfer the token to the buyer
        _transfer(address(this), msg.sender, tokenId);

        // transfer the funds to the seller
        payable(owner).transfer(listingPrice);

        // transfer the funds to the seller
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    // Function to get unsold NFT Data
    function fetchMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (idMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items
    }
}
