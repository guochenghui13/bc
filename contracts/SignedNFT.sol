// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./DIDRegistry.sol"; // 导入DIDRegistry合约

contract SignedNFT is ERC721URIStorage {
    using ECDSA for bytes32;

    uint256 private _tokenIdCounter;
    DIDRegistry private didRegistry; // 添加DIDRegistry合约实例变量

    event NFTMinted(address indexed to, uint256 indexed tokenId, string message);

    constructor(address _didRegistryAddress) ERC721("SignedNFT", "SNFT") {
        didRegistry = DIDRegistry(_didRegistryAddress); // 初始化DIDRegistry合约实例
    }

    function mintNFT(uint256 didId, string memory message, bytes memory signature, address to) public {
        DIDRegistry.DIDDocument memory didDocument = didRegistry.getDIDDocumentById(didId); // 通过ID获取DID文档

        bytes32 messageHash = keccak256(abi.encodePacked(message));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // 使用tryRecover，根据布尔值判断签名是否有效
        // 使用 tryRecover 而不是 recover
        (address signer, ECDSA.RecoverError error) = ethSignedMessageHash.tryRecover(signature);

        require(error == ECDSA.RecoverError.NoError, "Invalid signature");

        require(signer == didDocument.publicKey, "Invalid signer"); // 检查签名者是否与DID文档中的公钥对应的地址相同

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

    // 添加一个函数用于调用DIDRegistry合约的getDIDDocument方法
    function getDIDDocumentById(uint256 id) public view returns (DIDRegistry.DIDDocument memory) {
        return didRegistry.getDIDDocumentById(id);
    }
}
