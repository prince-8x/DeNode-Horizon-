// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DeNode Horizon
 * @dev A decentralized project management contract for milestone tracking and funding.
 */
contract Project {
    address public owner;
    uint256 public projectCount;

    struct ProjectInfo {
        uint256 id;
        string title;
        string description;
        uint256 funds;
        bool completed;
    }

    mapping(uint256 => ProjectInfo) public projects;

    event ProjectCreated(uint256 indexed id, string title);
    event FundAdded(uint256 indexed id, uint256 amount);
    event ProjectCompleted(uint256 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ✅ Function 1: Create new project
    function createProject(string memory _title, string memory _description) public onlyOwner {
        projectCount++;
        projects[projectCount] = ProjectInfo(projectCount, _title, _description, 0, false);
        emit ProjectCreated(projectCount, _title);
    }

    // ✅ Function 2: Fund a project
    function fundProject(uint256 _id) public payable {
        require(_id > 0 && _id <= projectCount, "Invalid project ID");
        require(!projects[_id].completed, "Project already completed");

        projects[_id].funds += msg.value;
        emit FundAdded(_id, msg.value);
    }

    // ✅ Function 3: Mark a project as completed
    function markCompleted(uint256 _id) public onlyOwner {
        require(!projects[_id].completed, "Already completed");
        projects[_id].completed = true;
        emit ProjectCompleted(_id);
    }
}
