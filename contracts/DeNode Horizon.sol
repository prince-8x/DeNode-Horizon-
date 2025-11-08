proportional reward
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
// 
End
// 
