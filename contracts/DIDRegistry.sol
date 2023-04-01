// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDRegistry {
    // DID文档的结构
    struct DIDDocument {
        uint256 id;
        address owner;
        address publicKey;
        string authentication;
        string serviceEndpoint;
    }

    // 使用DID作为键，将其映射到DID文档
    mapping(string => DIDDocument) public didDocuments;

    // 使用ID作为键，将其映射到DID
    mapping(uint256 => string) public dids;

    // 自增ID
    uint256 private nextID;

    // DID创建事件
    event DIDCreated(string indexed did, address indexed owner, uint256 id);

    // DID更新事件
    event DIDUpdated(string indexed did, address indexed owner);

    // DID删除事件
    event DIDDeleted(string indexed did, address indexed owner);

    constructor() {
        nextID = 1;
    }

    // 创建DID文档
    function createDID(
        string memory did,
        address publicKey,
        string memory authentication,
        string memory serviceEndpoint
    ) public {
        require(didDocuments[did].owner == address(0), "DID already exists");

        uint256 id = nextID;
        nextID++;

        didDocuments[did] = DIDDocument({
            id: id,
            owner: msg.sender,
            publicKey: publicKey,
            authentication: authentication,
            serviceEndpoint: serviceEndpoint
        });

        dids[id] = did;

        emit DIDCreated(did, msg.sender, id);
    }

    // 更新DID文档
    function updateDID(
        string memory did,
        address publicKey,
        string memory authentication,
        string memory serviceEndpoint
    ) public {
        require(didDocuments[did].owner == msg.sender, "Not authorized");

        didDocuments[did].publicKey = publicKey;
        didDocuments[did].authentication = authentication;
        didDocuments[did].serviceEndpoint = serviceEndpoint;

        emit DIDUpdated(did, msg.sender);
    }

    // 删除DID文档
    function deleteDID(string memory did) public {
        require(didDocuments[did].owner == msg.sender, "Not authorized");

        delete didDocuments[did];

        emit DIDDeleted(did, msg.sender);
    }

    // 根据ID获取DID
    function getDIDById(uint256 id) public view returns (string memory) {
        return dids[id];
    }

     // 添加一个函数用于根据ID获取DIDDocument
    function getDIDDocumentById(uint256 id) public view returns (DIDDocument memory) {
        string memory did = getDIDById(id);
        return didDocuments[did];
    }
}
