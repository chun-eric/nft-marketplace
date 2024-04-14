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

### Build the NFT Marketplace smart contract

Time to write the code for NFTMarketplace.sol
First download some libraries.

```
import "openzeppelin/contracts/utils/Counters.sol"; // using a counter for the token id
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // for the ERC721 token
import "@openzeppelin/contracts/token/ERC721/ERC721.sol
```

Check the errorhandling.md file. Errors #3 and #4 occured.
I also installed npm i dotenv here.

