// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract Tournament {
    // Contract owner
    address public owner;

    // Total reward pool
    uint256 public rewardPool;

    // Enumeration for match status
    enum MatchStatus { Pending, Completed }

    // Structure to represent a match
    struct Match {
        address team1;
        address team2;
        address winner;
        MatchStatus status;
    }

    // Structure to represent tournament information
    struct TournamentInfo {
        address[] teams;
        Match[] matches;
        address[] secondRoundTeams;
        address[] finalRoundTeams;
}

    // Mapping to store tournament information for each tournament ID
    mapping(uint256 => TournamentInfo) private tournaments;

    // Event emitted when a tournament is created
    event TournamentCreated(uint256 indexed tournamentId, address[] teams);

    // Event emitted when a match is completed
    event MatchCompleted(uint256 indexed tournamentId, uint256 matchIndex, address winner);

    // Modifier to ensure that only the owner of the contract can call a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Modifier to ensure that a tournament with the given ID exists
    modifier tournamentExists(uint256 _tournamentId) {
        require(tournaments[_tournamentId].teams.length > 0, "Tournament does not exist");
        _;
    }

    // Modifier to ensure that a tournament with the given ID has not started yet
    modifier tournamentNotStarted(uint256 _tournamentId) {
        require(tournaments[_tournamentId].matches.length == 0, "Tournament has already started");
        _;
    }
    uint256 public currentMatchIndex;
    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to retrieve the teams participating in a tournament
    function getTournamentTeams(uint256 _tournamentId) external view returns (address[] memory) {
        return tournaments[_tournamentId].teams;
    }

    // Function to retrieve the matches in a tournament
    function getTournamentMatches(uint256 _tournamentId) external view returns (Match[] memory) {
        return tournaments[_tournamentId].matches;
    }

    // Function to create a new tournament with the given ID and teams
    function createTournament(uint256 _tournamentId, address[] memory _teams) external onlyOwner tournamentNotStarted(_tournamentId) {
        require(_teams.length == 8 || _teams.length == 16, "Number of teams must be 8 or 16");

        TournamentInfo storage newTournament = tournaments[_tournamentId];
        newTournament.teams = _teams;

        emit TournamentCreated(_tournamentId, _teams);
    }

    // Function to start a tournament by generating initial matches
   function startTournament(uint256 _tournamentId) external onlyOwner tournamentExists(_tournamentId) {
        TournamentInfo storage tournament = tournaments[_tournamentId];
        uint256 numTeams = tournament.teams.length;

        require(numTeams % 2 == 0, "Number of teams must be even");

    // Check if the tournament has already started
        require(tournament.matches.length < numTeams - 1, "Tournament has already started");

        for (uint256 i = 0; i < numTeams / 2; i++) {
            tournament.matches.push(Match({
                team1: tournament.teams[i * 2],
                team2: tournament.teams[i * 2 + 1],
                winner: address(0),
                status: MatchStatus.Pending
            }));
        }

    // Set the current match index to 0 when starting the tournament
        currentMatchIndex = 0;
        }

    // Function to complete a match in a tournament and declare a winner
    function completeMatch(uint256 _tournamentId, uint256 _matchIndex, address _winner) public {
        TournamentInfo storage tournament = tournaments[_tournamentId];
        Match storage matchInstance = tournament.matches[_matchIndex];
        matchInstance.winner = _winner;
        matchInstance.status = MatchStatus.Completed;

        if (_matchIndex < tournament.teams.length / 2) {
            tournament.secondRoundTeams.push(_winner);
     }  else if (_matchIndex < tournament.teams.length / 2 + tournament.secondRoundTeams.length / 2) {
            tournament.finalRoundTeams.push(_winner);
        }

    // If the match being completed is the last match of the current round, create matches for the next round
        if (_matchIndex == tournament.teams.length / 2 - 1 || _matchIndex == tournament.teams.length / 2 + tournament.secondRoundTeams.length / 2 - 1) {
         address[] storage winners = _matchIndex == tournament.teams.length / 2 - 1 ? tournament.secondRoundTeams : tournament.finalRoundTeams;
            for (uint256 i = 0; i < winners.length / 2; i++) {
                tournament.matches.push(Match({
                    team1: winners[i * 2],
                    team2: winners[i * 2 + 1],
                    winner: address(0),
                    status: MatchStatus.Pending
                }));
            }
        }
    }

    event DebugRewardDistribution(uint256 indexed tournamentId, uint256 numMatches, uint256 numTeams);


   // Function to distribute rewards to the winning teams in a tournament
    function distributeRewards(uint256 _tournamentId) external onlyOwner tournamentExists(_tournamentId) {
        TournamentInfo storage tournament = tournaments[_tournamentId];
        require(tournament.matches.length == tournament.teams.length - 1, "Tournament not finished");
          console.log(rewardPool);
    // Calculate rewards for each place
        console.log("Ovde puca 1");
        uint256 firstPlaceReward = (rewardPool * 50) / 100;
        uint256 secondPlaceReward = (rewardPool * 30) / 100;
        uint256 thirdPlaceReward = (rewardPool * 10) / 100;
        uint256 fourthPlaceReward = (rewardPool * 10) / 100;
        console.log("Ovde puca 2");

    // Emit an event with reward information


    // Transfer rewards to each team
        address winner1 = tournament.matches[tournament.matches.length - 1].winner;
        address winner2 = tournament.matches[tournament.matches.length - 2].winner;
        address winner3 = tournament.matches[tournament.matches.length - 3].winner;
        address winner4 = tournament.matches[tournament.matches.length - 4].winner;
        console.log("Ovde puca 3");
        console.log(winner1);
        console.log(firstPlaceReward);


        payable(winner1).transfer(firstPlaceReward);
        payable(winner2).transfer(secondPlaceReward);
        payable(winner3).transfer(thirdPlaceReward);
        payable(winner4).transfer(fourthPlaceReward);
        console.log("Ovde puca 4");
    }

    function deposit() external payable {
        rewardPool += 11 ether;
    }


    
   

   
}
