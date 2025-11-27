// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title DeNodeHorizon
 * @notice A decentralized platform for registering, linking, and managing network nodes.
 */
contract DeNodeHorizon {

    address public admin;
    uint256 public nodeCount;

    struct Node {
        uint256 id;
        address owner;
        string nodeHash;          // Unique identifier or metadata (e.g., IPFS)
        string metadataURI;       // Optional node metadata
        uint256 timestamp;
        bool active;
        uint256 uptime;           // Tracked uptime in seconds
        uint256[] linkedNodes;
        uint256 rewards;          // Accumulated rewards
    }

    mapping(uint256 => Node) public nodes;
    mapping(address => uint256[]) public ownerNodes;

    event NodeRegistered(uint256 indexed id, address indexed owner, string nodeHash, string metadataURI);
    event NodeLinked(uint256 indexed fromId, uint256 indexed toId);
    event NodeActivated(uint256 indexed id);
    event NodeDeactivated(uint256 indexed id);
    event RewardDistributed(uint256 indexed id, uint256 amount);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "DeNodeHorizon: NOT_ADMIN");
        _;
    }

    modifier nodeExists(uint256 id) {
        require(id > 0 && id <= nodeCount, "DeNodeHorizon: NODE_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a new node
    function registerNode(string calldata nodeHash, string calldata metadataURI) external returns (uint256) {
        require(bytes(nodeHash).length > 0, "DeNodeHorizon: EMPTY_HASH");

        nodeCount++;
        nodes[nodeCount] = Node({
            id: nodeCount,
            owner: msg.sender,
            nodeHash: nodeHash,
            metadataURI: metadataURI,
            timestamp: block.timestamp,
            active: true,
            uptime: 0,
            linkedNodes: new uint256,
            rewards: 0
        });

        ownerNodes[msg.sender].push(nodeCount);

        emit NodeRegistered(nodeCount, msg.sender, nodeHash, metadataURI);
        return nodeCount;
    }

    /// @notice Link two nodes (bi-directionally)
    function linkNodes(uint256 fromId, uint256 toId) external nodeExists(fromId) nodeExists(toId) {
        require(fromId != toId, "DeNodeHorizon: SELF_LINK");
        require(nodes[fromId].owner == msg.sender || msg.sender == admin, "DeNodeHorizon: UNAUTHORIZED");

        nodes[fromId].linkedNodes.push(toId);
        nodes[toId].linkedNodes.push(fromId);

        emit NodeLinked(fromId, toId);
        emit NodeLinked(toId, fromId);
    }

    /// @notice Activate a node
    function activateNode(uint256 id) external nodeExists(id) {
        Node storage n = nodes[id];
        require(msg.sender == n.owner || msg.sender == admin, "DeNodeHorizon: UNAUTHORIZED");
        n.active = true;
        emit NodeActivated(id);
    }

    /// @notice Deactivate a node
    function deactivateNode(uint256 id) external nodeExists(id) {
        Node storage n = nodes[id];
        require(msg.sender == n.owner || msg.sender == admin, "DeNodeHorizon: UNAUTHORIZED");
        n.active = false;
        emit NodeDeactivated(id);
    }

    /// @notice Distribute rewards to a node (admin-controlled)
    function distributeRewards(uint256 id, uint256 amount) external onlyAdmin nodeExists(id) {
        Node storage n = nodes[id];
        n.rewards += amount;
        emit RewardDistributed(id, amount);
    }

    /// @notice Get node info
    function getNode(uint256 id) external view nodeExists(id) returns (Node memory) {
        return nodes[id];
    }

    /// @notice Get all nodes owned by a user
    function getUserNodes(address owner) external view returns (uint256[] memory) {
        return ownerNodes[owner];
    }

    /// @notice Change admin
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "DeNodeHorizon: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
