// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";

/// @title A dynamic NFT collection that changes 
/// from a seed to a flower bloom
/// @author William Phan
/// @custom:experimental This is an experimental contract.
contract Switch is ERC721, ERC721URIStorage {
    
    /// @notice used to keep track of the number of unique ERC721 tokens
    using Counters for Counters.Counter;

    /// @notice keeps track of tokenIds
    Counters.Counter private _tokenIdCounter;
 
   /// @notice 3 pictures and their ipfs links are below
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json"
    ]; 

    /// @notice This is used to keep track of last timestamp
    uint256 lastTimeStamp;

    /// @notice This is used to keep track of the time since 
    /// the last timestamp
    uint256 interval;

    /// @notice initializes the _interval and ERC721 token
    /// contract name and symbol
    /// @param _interval the interval to keep track of last timestamp.
    /// Time in seconds between Chainlink upkeeps
    constructor(uint _interval) ERC721("dNFTs", "dNFT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    /// @notice checks if Chainlink upkeep is needed
    /// based on interval and last timestamp
    /// @return upkeepNeeded bool true or false 
    /// @return performData memory 
    function checkUpkeep() external view  returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    /// @notice checks if given interval has expired and if so, calls growFlower()
    /// @param performData bytes calldata 
    function performUpkeep(bytes calldata performData) external  {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            growFlower(0);
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    /// @notice function to mint new token on Ethereum blockchain
    /// @param to address of recipient
    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    /// @notice function to increase the stage of the flower by 1
    /// also updates assaciated token's URI with the new stage's URI
    /// @param _tokenId token Id number
    function growFlower(uint256 _tokenId) public {
        if(flowerStage(_tokenId) >= 2){return;}
        // Get the current stage of the flower and add 1
        uint256 newVal = flowerStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = IpfsUri[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }
/* 
    ********************
    * HELPER FUNCTIONS *
    ********************
*/ 

    /// @notice determines the stage of the flower growth
    /// @param _tokenId takes in the token Id
    /// @return uint256 the stage of the flower
    function flowerStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Seed
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Sprout
        if (
            compareStrings(_uri, IpfsUri[1]) 
        ) {
            return 1;
        }
        // Must be a Bloom
        return 2;
    }

    /// @notice helper function to compare strings
    /// @param a string to compare
    /// @param b string to compare
    /// @return bool same or different
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    /// @notice _burn function required as an overide from Solidity
    /// @param tokenId uint256
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /// @notice tokenURI function required as an overide from Solidity
    /// @param tokenId uint256
    /// @return tokenId
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}