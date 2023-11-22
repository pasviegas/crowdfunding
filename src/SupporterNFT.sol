pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SupporterNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string private baseURI;

    constructor(string memory _baseImageUri) ERC721("SupporterNFT", "SUP") Ownable(_msgSender()) {
        baseURI = _baseImageUri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}
