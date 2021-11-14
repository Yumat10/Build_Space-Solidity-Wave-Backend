// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    uint256 private seed; // Utilized to replicate some randomness

    mapping(address => uint256) public lastWavedAt; // Store time when user last waved

    // Event to keep track of when a user waves
    event NewWave(address indexed from, uint256 timeStamp, string message);

    // Structs define a custom datatype where the data inside it is set
    struct Wave {
        address waver; // address of user who waved
        string message; // message sent by user
        uint256 timeStamp; // timestamp of when user waved
    }

    // Keeps track of all of the waves sent in an array
    Wave[] waves;

    constructor() payable {
        console.log("Contract constructed");
        // Set initial seed
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        // Check to make sure the user has not waved in the last minute
        require(
            lastWavedAt[msg.sender] + 1 minutes < block.timestamp,
            "Wait at least 1 min"
        );

        // Update user's last waved timestamp
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        // Store wave in the array
        waves.push(Wave(msg.sender, _message, block.timestamp));

        // Generate new seed for the next user to make it harder to game the system
        // Note we use the previous seed
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("New seed:", seed);

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );

            (bool success, ) = (msg.sender).call{value: prizeAmount}("");

            // Transfer prize amount to user
            require(success, "Failed to withdraw money from contract.");
        }

        // Notify all viewers of a new wave
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }
}
