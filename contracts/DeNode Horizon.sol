// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title DeNode Horizon
 * @notice A decentralized node coordination and reputation protocol for cross-chain networks.
 *         It enables node operators to register, maintain uptime scores, and get rewarded
 *         based on performance and reliability.
 */
contract Project {
    address public admin;
    uint256 public nodeCount;

    struct Node {
        uint256 id;
        address operator;
        string metadataURI;
        uint256 uptimeScore;
        uint256 stakedAmount;
        bool active;
        uint256 registeredAt;
    }

    mapping(uint256 => Node) public nodes;
    mapping(address => bool) public registeredOperators;

    event NodeRegistered(uint256 indexed id, address indexed operator, string metadataURI, uint256 stake);
    event NodeStatusUpdated(uint256 indexed id, bool active);
    event UptimeReported(uint256 indexed id, uint256 newScore);
    event RewardsDistributed(address indexed operator, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    modifier onlyOperator(uint256 _id) {
        require(nodes[_id].operator == msg.sender, "Not the node operator");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Register a new node in the network
     * @param _metadataURI Metadata or info link for the node (IPFS or web URI)
     */
    function registerNode(string memory _metadataURI) external payable {
        require(!registeredOperators[msg.sender], "Already registered");
        require(msg.value >= 0.01 ether, "Minimum 0.01 ETH stake required");

        nodeCount++;
        nodes[nodeCount] = Node(nodeCount, msg.sender, _metadataURI, 100, msg.value, true, block.timestamp);
        registeredOperators[msg.sender] = true;

        emit NodeRegistered(nodeCount, msg.sender, _metadataURI, msg.value);
    }

    /**
     * @notice Report uptime performance for a node
     * @param _id Node ID
     * @param _score New uptime score (0–100)
     */
    function reportUptime(uint256 _id, uint256 _score) external onlyAdmin {
        require(_score <= 100, "Invalid score");
        require(nodes[_id].active, "Node is inactive");

        nodes[_id].uptimeScore = _score;
        emit UptimeReported(_id, _score);
    }

    /**
     * @notice Update node’s active/inactive status
     * @param _id Node ID
     * @param _active New active status
     */
    function updateNodeStatus(uint256 _id, bool _active) external onlyAdmin {
        nodes[_id].active = _active;
        emit NodeStatusUpdated(_id, _active);
    }

    /**
     * @notice Distribute rewards to a node operator based on uptime performance
     * @param _id Node ID
     */
    function distributeRewards(uint256 _id) external onlyAdmin {
        Node storage node = nodes[_id];
        require(node.active, "Inactive node");
        require(node.uptimeScore > 50, "Low uptime score");

        uint256 reward = (node.uptimeScore * 1e15); // proportional reward
        payable(node.operator).transfer(reward);

        emit RewardsDistributed(node.operator, reward);
    }

    /**
     * @notice Get details of a specific node
     * @param _id Node ID
     */
    function getNode(uint256 _id) external view returns (Node memory) {
        return nodes[_id];
    }
}
