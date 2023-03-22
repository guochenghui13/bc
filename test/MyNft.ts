import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SignedNFT", function () {
  async function deploySignedNFTFixture() {
    const [owner, user, verifier] = await ethers.getSigners();

    const SignedNFT = await ethers.getContractFactory("SignedNFT");
    const signedNFT = await SignedNFT.deploy(verifier.address);

    return { signedNFT, verifier, user };
  }

  describe("Minting NFT", function () {
    it("Should mint NFT when provided with valid signature", async function () {
      const { signedNFT, verifier, user } = await loadFixture(deploySignedNFTFixture);

      const message = "Hello, NFT!";
      const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));
      const signature = await verifier.signMessage(ethers.utils.arrayify(messageHash));

      await signedNFT.mintNFT(message, signature, user.address);

      const tokenId = 1;
      expect(await signedNFT.ownerOf(tokenId)).to.equal(user.address);
      expect(await signedNFT.tokenURI(tokenId)).to.equal(message);
    });

    it("Should fail to mint NFT when provided with invalid signature", async function () {
      const { signedNFT, verifier, user } = await loadFixture(deploySignedNFTFixture);
    
      const message = "Hello, NFT!";
      const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));
    
      // 使用一个具有正确长度但仍然无效的签名
      const invalidSignature = "0x" + "12".repeat(65); // 65字节长度的无效签名
    
      await expect(signedNFT.mintNFT(message, invalidSignature, user.address)).to.be.revertedWith("Invalid signature");
    });
    
  });
});
