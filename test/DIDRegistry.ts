import { expect } from "chai";
import { ethers } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";


describe("DIDRegistry", function () {
  async function deployDIDRegistryFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
    const didRegistry = await DIDRegistry.deploy();

    return { didRegistry, owner, otherAccount };
  }

  describe("DID Operations", function () {
    const did = "did:example:1234567890";
    const publicKey = "publicKeyExample";
    const authentication = "authenticationExample";
    const serviceEndpoint = "serviceEndpointExample";

    it("Should create a new DID", async function () {
      const { didRegistry } = await loadFixture(deployDIDRegistryFixture);

      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);

      const didDocument = await didRegistry.didDocuments(did);
      expect(didDocument.id).to.equal(1);
      expect(didDocument.publicKey).to.equal(publicKey);
      expect(didDocument.authentication).to.equal(authentication);
      expect(didDocument.serviceEndpoint).to.equal(serviceEndpoint);
    });

    it("Should update an existing DID", async function () {
      const { didRegistry } = await loadFixture(deployDIDRegistryFixture);

      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);

      const newPublicKey = "newPublicKeyExample";
      const newAuthentication = "newAuthenticationExample";
      const newServiceEndpoint = "newServiceEndpointExample";

      await didRegistry.updateDID(did, newPublicKey, newAuthentication, newServiceEndpoint);

      const didDocument = await didRegistry.didDocuments(did);
      expect(didDocument.publicKey).to.equal(newPublicKey);
      expect(didDocument.authentication).to.equal(newAuthentication);
      expect(didDocument.serviceEndpoint).to.equal(newServiceEndpoint);
    });

    it("Should not update a DID if not the owner", async function () {
      const { didRegistry, otherAccount } = await loadFixture(deployDIDRegistryFixture);

      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);

      const newPublicKey = "newPublicKeyExample";
      const newAuthentication = "newAuthenticationExample";
      const newServiceEndpoint = "newServiceEndpointExample";

      await expect(
        didRegistry.connect(otherAccount).updateDID(did, newPublicKey, newAuthentication, newServiceEndpoint)
      ).to.be.revertedWith("Not authorized");
    });

    it("Should delete an existing DID", async function () {
      const { didRegistry } = await loadFixture(deployDIDRegistryFixture);

      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);
      await didRegistry.deleteDID(did);

      const didDocument = await didRegistry.didDocuments(did);
      expect(didDocument.owner).to.equal(ethers.constants.AddressZero);
    });

    it("Should not delete a DID if not the owner", async function () {
      const { didRegistry, otherAccount } = await loadFixture(deployDIDRegistryFixture);

      await didRegistry.createDID(did, publicKey, authentication, serviceEndpoint);
      await expect(didRegistry.connect(otherAccount).deleteDID(did)).to.be.revertedWith("Not authorized");
    });
  });
});
