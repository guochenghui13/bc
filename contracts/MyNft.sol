// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignedNFT is ERC721URIStorage {
    using ECDSA for bytes32;

    uint256 private _tokenIdCounter;
    address public verifierPublicKey;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string message);

    constructor(address _verifierPublicKey) ERC721("SignedNFT", "SNFT") {
        verifierPublicKey = _verifierPublicKey;
    }

    function mintNFT(string memory message, bytes memory signature, address to) public {
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

         // 使用tryRecover，根据布尔值判断签名是否有效
       // 使用 tryRecover 而不是 recover
        (address signer,ECDSA.RecoverError error) = ethSignedMessageHash.tryRecover(signature);

        require(error == ECDSA.RecoverError.NoError, "Invalid signature");
        require(signer == verifierPublicKey, "Invalid signer");


        _tokenIdCounter += 1;
        uint256 tokenId = _tokenIdCounter;

        _mint(to, tokenId);
        _setTokenURI(tokenId, message);

        emit NFTMinted(to, tokenId, message);
    }
}
