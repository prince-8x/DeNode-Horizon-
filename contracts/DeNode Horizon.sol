? Function 1: Create new project
    function createProject(string memory _title, string memory _description) public onlyOwner {
        projectCount++;
        projects[projectCount] = ProjectInfo(projectCount, _title, _description, 0, false);
        emit ProjectCreated(projectCount, _title);
    }

    ? Function 3: Mark a project as completed
    function markCompleted(uint256 _id) public onlyOwner {
        require(!projects[_id].completed, "Already completed");
        projects[_id].completed = true;
        emit ProjectCompleted(_id);
    }
}
// 
update
// 
