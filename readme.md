# NFT Project Walkthrough

### Initialize the project

Use npm init
Setup your github repo
Initialize hardhat - install hardhat

```
npm install --save-dev hardhat
npx hardhat init
```

I had to reinstall node. Installed the node lts version so that hardhat can be used with node.

If error #2 is occuring which is the initialization error, then type the following code.

```
npx hardhat --verbose
```

This will fix the bug.
Choose your options and wait for hardhat to finish install.

### File cleanup

delete the Lock.sol contract
Make a new contract called NFTMarketplace.sol

the deploy script is now changed to the ignition modules Lock.js

package.json has all the project details including all devDepencies

### Install open Zepplin

Open zepplin is a great framework to build smart contracts.

Download open zepplin from the terminal at:

```
npm install @openzeppelin/contracts
```

After downloading its time to build the smart contract.

### Install libraries for our NFT Marketplace smart contract

Time to write the code for NFTMarketplace.sol
First download some libraries.

```
import "openzeppelin/contracts/utils/Counters.sol"; // using a counter for the token id
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // for the ERC721 token
import "@openzeppelin/contracts/token/ERC721/ERC721.sol
```

Check the errorhandling.md file. Errors #3 and #4 occured.

We also need to import hardhat console.

```
import "hardhat/console.sol";
```

I also installed npm i dotenv here.

### Writing our smart contract

```
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
    event MarketItemCreated(
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

    // create a NFT Token function

}
```

### Create a new NFT token function

First we need to make a function that creates a NFT Token.

````
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
    ```
````

A createMarketItem function needs to be created so that we can create a market item.

````
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
    ```
````

We also have to create a function when an owner sells a NFT.

```
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

```

Lets create a function for when a nft market is sold by the owner

```
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

```
