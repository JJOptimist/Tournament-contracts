// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/Tournament.sol"; 

contract TournamentTest {
    Tournament tournament;

    function beforeAll() public {
        tournament = new Tournament();
       
    }

    
    function testTournamentFlow() public {
        address[] memory teams = new address[](8);
        teams[0] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        teams[1] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        teams[2] = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        teams[3] = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        teams[4] = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
        teams[5] = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        teams[6] = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
        teams[7] = 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C;

         // Create tournament
        tournament.createTournament(1, teams);
        Assert.equal(tournament.getTournamentTeams(1).length, 8, "Number of teams in the tournament should be 8");

        // Start tournament
        tournament.startTournament(1);
 
       

        // Complete matches and check winners
        tournament.completeMatch(1, 0, teams[0]);
        tournament.completeMatch(1, 1, teams[2]);
        tournament.completeMatch(1, 2, teams[4]);
        tournament.completeMatch(1, 3, teams[6]);
        tournament.completeMatch(1, 4, teams[0]);
        tournament.completeMatch(1, 5, teams[4]);
        tournament.completeMatch(1, 6, teams[0]);

        Assert.equal(tournament.getTournamentMatches(1).length, 7, "Number of matches in the tournament should be 7");

        // Check winners
        Assert.equal(tournament.getTournamentMatches(1)[0].winner, teams[0], "Team0 should win the first match");
        Assert.equal(tournament.getTournamentMatches(1)[1].winner, teams[2], "Team2 should win the second match");
        Assert.equal(tournament.getTournamentMatches(1)[2].winner, teams[4], "Team4 should win the third match");
        Assert.equal(tournament.getTournamentMatches(1)[3].winner, teams[6], "Team6 should win the fourth match");
        Assert.equal(tournament.getTournamentMatches(1)[4].winner, teams[0], "Team0 should win the fifth match");
        Assert.equal(tournament.getTournamentMatches(1)[5].winner, teams[4], "Team4 should win the sixth match");
        Assert.equal(tournament.getTournamentMatches(1)[6].winner, teams[0], "Team0 should win the seventh match");

        // Distribute rewards
        tournament.distributeRewards(1);

        // Check balances
        Assert.equal(address(0).balance, 0, "Balance of address(0) should be 0");
        Assert.equal(payable(teams[0]).balance, 5 ether, "Team0 should receive 50% reward");
        Assert.equal(payable(teams[4]).balance, 3 ether, "Team4 should receive 30% reward");
        Assert.equal(payable(teams[2]).balance, 1 ether, "Team2 should receive 10% reward");
        Assert.equal(payable(teams[6]).balance, 1 ether, "Team6 should receive 10% reward");
    }
}
