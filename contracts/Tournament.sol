// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        Match[] matches;
        address[] teams;
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

        for (uint256 i = 0; i < numTeams / 2; i++) {
            tournament.matches.push(Match({
                team1: tournament.teams[i * 2],
                team2: tournament.teams[i * 2 + 1],
                winner: address(0),
                status: MatchStatus.Pending
            }));
        }
    }

    // Function to complete a match in a tournament and declare a winner
    function completeMatch(uint256 _tournamentId, uint256 _matchIndex, address _winner) external onlyOwner tournamentExists(_tournamentId) {
        TournamentInfo storage tournament = tournaments[_tournamentId];
        require(_matchIndex < tournament.matches.length, "Invalid match index");
        require(tournament.matches[_matchIndex].status == MatchStatus.Pending, "Match already completed");
    
    // Allow the same team to win multiple matches
    // require(_winner == tournament.matches[_matchIndex].team1 || _winner == tournament.matches[_matchIndex].team2, "Invalid winner");

        tournament.matches[_matchIndex].winner = _winner;
        tournament.matches[_matchIndex].status = MatchStatus.Completed;

        emit MatchCompleted(_tournamentId, _matchIndex, _winner);
}

    event DebugRewardDistribution(uint256 indexed tournamentId, uint256 numMatches, uint256 numTeams);


   // Function to distribute rewards to the winning teams in a tournament
    function distributeRewards(uint256 _tournamentId) external onlyOwner tournamentExists(_tournamentId) {
        TournamentInfo storage tournament = tournaments[_tournamentId];
        emit DebugRewardDistribution(_tournamentId, tournament.matches.length, tournament.teams.length);
        require(tournament.matches.length == tournament.teams.length - 1, "Tournament not finished");
        

    // Calculate rewards for each place
        uint256 firstPlaceReward = (rewardPool * 50) / 100;
        uint256 secondPlaceReward = (rewardPool * 30) / 100;
        uint256 thirdPlaceReward = (rewardPool * 10) / 100;
        uint256 fourthPlaceReward = (rewardPool * 10) / 100;

    // Distribute rewards to each team
        payable(tournament.matches[tournament.matches.length - 1].winner).transfer(firstPlaceReward);
        payable(tournament.matches[tournament.matches.length - 2].winner).transfer(secondPlaceReward);
        payable(tournament.matches[tournament.matches.length - 3].winner).transfer(thirdPlaceReward);
        payable(tournament.matches[tournament.matches.length - 4].winner).transfer(fourthPlaceReward);
    }

}
