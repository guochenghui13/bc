import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SignedNFT", function () {
  async function deploySignedNFTFixture() {
    const [owner, user, verifier] = await ethers.getSigners();

    // 部署DIDRegistry合约
    const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
    const didRegistry = await DIDRegistry.deploy();

    const SignedNFT = await ethers.getContractFactory("SignedNFT");
    // 将DIDRegistry合约地址传递给SignedNFT合约
    const signedNFT = await SignedNFT.deploy(didRegistry.address);

    return { signedNFT, verifier, user, didRegistry };
  }

  describe("Minting NFT", function () {
    it("Should mint NFT when provided with valid signature and get DID by ID", async function () {
      const { signedNFT, verifier, user, didRegistry } = await loadFixture(deploySignedNFTFixture);

      // 创建一个DID以供测试
      const did = "did:example:123456789abcdefghi";
      const publicKey = verifier.address;  

      const authentication = "authentication";
      const serviceEndpoint = "serviceEndpoint";
      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);

      // 获取新创建的DID的ID
      const didId = 1;

      const message = "Hello, NFT!";
      const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));
      const signature = await verifier.signMessage(ethers.utils.arrayify(messageHash));

      await signedNFT.mintNFT(didId, message, signature, user.address);

      const tokenId = 1;
      expect(await signedNFT.ownerOf(tokenId)).to.equal(user.address);
      expect(await signedNFT.tokenURI(tokenId)).to.equal(message);

      // 调用getDIDById函数并验证返回的DID是否正确
      const retrievedDid = await signedNFT.getDIDById(1);
      expect(retrievedDid).to.equal(did);
    });

    it("Should fail to mint NFT when provided with invalid signature", async function () {
      const { signedNFT, verifier, user, didRegistry } = await loadFixture(deploySignedNFTFixture);
    
      // 创建一个DID以供测试
      const did = "did:example:123456789abcdefghi";
      const publicKey = await verifier.getAddress();
      const authentication = "authentication";
      const serviceEndpoint = "serviceEndpoint";
      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);

      // 获取新创建的DID的ID
      const didId = 1;

      const message = "Hello, NFT!";
      const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));
    
      // 使用一个具有正确长度但仍然无效的签名
      const invalidSignature = "0x" + "12".repeat(65); // 65字节长度的无效签名
    
      await expect(signedNFT.mintNFT(didId, message, invalidSignature, user.address)).to.be.revertedWith("Invalid signature");
    });

  });
});

