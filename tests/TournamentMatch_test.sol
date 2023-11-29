// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/Tournament.sol"; 

contract TournamentTest {
    Tournament tournament;

    function beforeAll() public {
        tournament = new Tournament();
    }

    function beforeEach() public {
        
    }

    function testTournamentFlow() public {
        address[] memory teams = new address[](8);
        teams[0] = 0xb3D9cf8E163bbc840195a97E81F8A34E295B8f39;
        teams[1] = 0x79457d3C630b1D095A7ECcB993232D395ebFc54d;
        teams[2] = 0xE086D858c555AfAe2Da9E86c067794Ba2046C339;
        teams[3] = 0x388C818CA8B9251b393131C08a736A67ccB19297;
        teams[4] = 0xcDBF58a9A9b54a2C43800c50C7192946dE858321;
        teams[5] = 0x21BEB3DE554042b3E626D7b1a7bf0Af7921bfd5f;
        teams[6] = 0xd4E96eF8eee8678dBFf4d535E033Ed1a4F7605b7;
        teams[7] = 0xe688b84b23f322a994A53dbF8E15FA82CDB71127;


         // Create tournament
        tournament.createTournament(1, teams);
        Assert.equal(tournament.getTournamentTeams(1).length, 8, "Number of teams in the tournament should be 8");

        // Start tournament
        tournament.startTournament(1);
        Assert.equal(tournament.getTournamentMatches(1).length, 4, "Number of matches in the tournament should be 4");

        // Complete matches and check winners
        tournament.completeMatch(1, 0, 0x79457d3C630b1D095A7ECcB993232D395ebFc54d);
        tournament.completeMatch(1, 1, 0x388C818CA8B9251b393131C08a736A67ccB19297);
        tournament.completeMatch(1, 2, 0xcDBF58a9A9b54a2C43800c50C7192946dE858321);
        tournament.completeMatch(1, 3, 0x79457d3C630b1D095A7ECcB993232D395ebFc54d);

        // Check winners
        Assert.equal(tournament.getTournamentMatches(1)[0].winner, 0x79457d3C630b1D095A7ECcB993232D395ebFc54d, "Team2 should win the first match");
        Assert.equal(tournament.getTournamentMatches(1)[1].winner, 0x388C818CA8B9251b393131C08a736A67ccB19297, "Team4 should win the second match");
        Assert.equal(tournament.getTournamentMatches(1)[2].winner, 0xcDBF58a9A9b54a2C43800c50C7192946dE858321, "Team5 should win the third match");
        Assert.equal(tournament.getTournamentMatches(1)[3].winner, 0x79457d3C630b1D095A7ECcB993232D395ebFc54d, "Team2 should win the finals");

        // Distribute rewards
        tournament.distributeRewards(1);

        // Check balances
        Assert.equal(address(0).balance, 0, "Balance of address(0) should be 0");
        Assert.equal(0x79457d3C630b1D095A7ECcB993232D395ebFc54d.balance, 5 ether, "Team2 should receive 50% reward");
        Assert.equal(0xcDBF58a9A9b54a2C43800c50C7192946dE858321.balance, 3 ether, "Team5 should receive 30% reward");
        Assert.equal(0x388C818CA8B9251b393131C08a736A67ccB19297.balance, 1 ether, "Team4 should receive 10% reward");
        Assert.equal(0xd4E96eF8eee8678dBFf4d535E033Ed1a4F7605b7.balance, 1 ether, "Team7 should receive 10% reward");
    }
}
