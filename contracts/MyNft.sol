// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./DIDRegistry.sol"; // 导入DIDRegistry合约

contract SignedNFT is ERC721URIStorage {
    using ECDSA for bytes32;

    uint256 private _tokenIdCounter;
    address public verifierPublicKey;
    DIDRegistry private didRegistry; // 添加DIDRegistry合约实例变量

    event NFTMinted(address indexed to, uint256 indexed tokenId, string message);

    constructor(address _verifierPublicKey, address _didRegistryAddress) ERC721("SignedNFT", "SNFT") {
        verifierPublicKey = _verifierPublicKey;
        didRegistry = DIDRegistry(_didRegistryAddress); // 初始化DIDRegistry合约实例
    }

    function mintNFT(string memory message, bytes memory signature, address to) public {
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // 使用tryRecover，根据布尔值判断签名是否有效
        // 使用 tryRecover 而不是 recover
        (address signer, ECDSA.RecoverError error) = ethSignedMessageHash.tryRecover(signature);

        require(error == ECDSA.RecoverError.NoError, "Invalid signature");
        require(signer == verifierPublicKey, "Invalid signer");

        _tokenIdCounter += 1;
        uint256 tokenId = _tokenIdCounter;

        _mint(to, tokenId);
        _setTokenURI(tokenId, message);

        emit NFTMinted(to, tokenId, message);
    }

    // 添加一个函数用于调用DIDRegistry合约的getDIDById方法
    function getDIDById(uint256 id) public view returns (string memory) {
        return didRegistry.getDIDById(id);
    }
}
