# Explore Report

## ERC721 和 ERC721URIStorage
ERC721 和 ERC721URIStorage 都是以太坊上的智能合约标准，用于实现非同质化代币（NFT）的创建和管理。它们的区别在于存储代币元数据的方式不同。

ERC721 定义了一组标准接口，用于实现 NFT 的创建、交易和转移等功能。在 ERC721 标准中，并没有定义如何存储 NFT 的元数据，即 NFT 的附加信息。通常情况下，元数据需要通过外部服务来存储和获取。例如，可以使用 IPFS 存储 NFT 元数据，然后将 IPFS 中的哈希值存储到 ERC721 合约中。当需要访问 NFT 的元数据时，可以使用 IPFS 的哈希值来获取。

而 ERC721URIStorage 则是基于 ERC721 标准扩展了一个新的功能，即在合约中存储和管理 NFT 的元数据。它添加了两个新的接口 tokenURI 和 setTokenURI，用于获取和设置 NFT 的元数据。这样，在使用 ERC721URIStorage 创建 NFT 时，可以直接在合约中存储 NFT 的元数据，而不需要依赖外部服务。

因此，与 ERC721 相比，使用 ERC721URIStorage 创建 NFT 可以更方便地管理 NFT 的元数据，但需要注意的是，存储大量的元数据可能会使得合约的大小变得很大，从而增加了合约的部署成本和交易成本。同时，存储在合约中的元数据是公开的，任何人都可以访问，这可能会引发一些安全问题，需要合理设计和管理。


## 有哪些基于solidity的加密算法库

* HashLib：提供了一系列哈希算法的 Solidity 实现，包括 MD5、SHA1、SHA256 等。
* CryptoLib：提供了一系列加密算法的 Solidity 实现，包括 AES、RSA、HMAC 等。
* EllipticCurve：提供了一些椭圆曲线加密算法的 Solidity 实现，如椭圆曲线 Diffie-Hellman（ECDH）算法等。
* Secp256k1：提供了 secp256k1 椭圆曲线加密算法的 Solidity 实现，该算法是比特币使用的签名算法。
* ECDSA.sol 是一个由 OpenZeppelin 提供的 Solidity 库，它提供了一些用于椭圆曲线数字签名算法（ECDSA）的实用函数


## 具体流程

```json

{
  "school": "ABC大学",
  "graduation_date": "2022-06-30",
  "name": "张三",
  "major": "计算机科学与技术"
}

以及对应的消息摘要的签名

Pk(Hash(Message)) + Message

将这个消息调用智能合约, 智能合约使用硬编码的大学的公钥匙进行解密, 判断消息是否合法, 如果合法给调用者的钱包地址分发nft, 并且里面的内容是消息的本身

```