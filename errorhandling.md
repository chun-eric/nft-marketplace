This is a list of all the errors and problems I have encountered during the project

1. Node version incompatability - had to upgrade to latest node lts
2. Hardhat reinitializing error. There is a bug that if you quit hardhat project configuration before completion, it doesnt start up again - had to type `npx hardhat --verbose`
3. import "@openzeppelin/contracts/utils/Counters.sol"; // keeps track of how many items are being created and sold
   import "@openzepplin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // for the ERC721 token
   import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

The import for the above openzepplin is not found.

- Apparently the Counter utils was removed in openzepplin 5.0.0. and above. Counter was part of the Safemath. Safemath is not used due to underflow and overflow issues in solidity version 8.

Now you have to manually increment yourself.

If we want to use the Counters then we need to downgrade openzepplin to 4.9.3

```
npm i @openzeppelin/contracts@4.9.3
```

4. cant find the:

```
@openzepplin/contracts/token/ERC721/extensions/ERC721URIStorage.sol
```

- After some research the url was:

```
@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol
```

Not quite sure what the error was. Both URL looks exactly the same.
