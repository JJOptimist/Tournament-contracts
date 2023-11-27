// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "remix_tests.sol"; // Import the Remix testing library
import "../contracts/Tournament.sol"; // Import the contract to be tested

contract TournamentTest {
    Tournament tournament;

    function beforeEach() public {
        tournament = new Tournament(); // Deploy a new instance of the contract for each test
    }

    function testCreateTournament() public {
        address[] memory teams = new address[](8);

        teams[0] = 0xb3D9cf8E163bbc840195a97E81F8A34E295B8f39;
        teams[1] = 0x79457d3C630b1D095A7ECcB993232D395ebFc54d;
        teams[2] = 0xE086D858c555AfAe2Da9E86c067794Ba2046C339;
        teams[3] = 0x388C818CA8B9251b393131C08a736A67ccB19297;
        teams[4] = 0xcDBF58a9A9b54a2C43800c50C7192946dE858321;
        teams[5] = 0x21BEB3DE554042b3E626D7b1a7bf0Af7921bfd5f;
        teams[6] = 0x388C818CA8B9251b393131C08a736A67ccB19297;
        teams[7] = 0xe688b84b23f322a994A53dbF8E15FA82CDB71127;

        tournament.createTournament(1, teams);

        // Check that the tournament was created successfully
        Assert.equal(tournament.getTournamentTeams(1).length, teams.length, "Tournament should have the correct number of teams");
    }

    // Add more test functions as needed...

    // Helper function to get the deployed contract
    function getDeployedTournament() public view returns (Tournament) {
        return tournament;
    }
}
