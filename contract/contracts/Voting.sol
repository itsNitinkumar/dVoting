// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voting {
    address public admin;

    struct Candidate {
        string name;
        uint age;
        bool registered;
        address candidateAddress;
        uint votes;
    }

    struct Voter {
        bool registered;
        bool voted;
    }

    struct Election {
        string eventName;
        bool voteInProgress;
        uint voteCount;
        address winnerAddress;
        mapping(address => uint) isCandidate;
        Candidate[] candidateList;
        mapping(address => Voter) voterList;
        bool exists;
    }

    event success(string msg);
    mapping(uint => Election) public elections;
    uint public electionCount;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can perform this action");
        _;
    }

    function createElection(string calldata _eventName) external onlyAdmin {
        electionCount++;
        elections[electionCount].eventName = _eventName;
        elections[electionCount].voteInProgress = false;
        elections[electionCount].voteCount = 0;
        elections[electionCount].exists = true;

        emit success("Election created");
    }

    struct ElectionSummary {
        string eventName;
        bool voteInProgress;
        uint voteCount;
        address winnerAddress;
        bool exists;
    }

    function getElections() external view returns (ElectionSummary[] memory) {
        ElectionSummary[] memory _elections = new ElectionSummary[](electionCount);
        for (uint i = 1; i <= electionCount; i++) {
            Election storage election = elections[i];
            _elections[i - 1] = ElectionSummary({
                eventName: election.eventName,
                voteInProgress: election.voteInProgress,
                voteCount: election.voteCount,
                winnerAddress: election.winnerAddress,
                exists: election.exists
            });
        }
        return _elections;
    }

    function getElectionCount() external view returns (uint) {
        return electionCount;
    }

    function registerCandidates(uint _electionId, string calldata _name, uint _age, address _candidateAddress) external onlyAdmin {
        require(elections[_electionId].exists, "Election does not exist");
        require(_candidateAddress != admin, "admin cannot be the candidate");
        require(elections[_electionId].isCandidate[_candidateAddress] == 0, "Candidate already registered");

        Election storage election = elections[_electionId];
        Candidate memory candidate = Candidate({
            name: _name,
            age: _age,
            registered: true,
            votes: 0,
            candidateAddress: _candidateAddress
        });

        if(election.candidateList.length == 0) { // leaving index 0 to check if candidate is registered
            election.candidateList.push();
        }
        
        election.isCandidate[_candidateAddress] = election.candidateList.length;
        election.candidateList.push(candidate);

        emit success("Candidate registered");
    }

    function verifyVoter(uint _electionId, address _voterAddress) external onlyAdmin {
        require(elections[_electionId].exists, "Election does not exist");
        require(_voterAddress != admin, "admin cannot vote");
        require(!elections[_electionId].voterList[_voterAddress].registered, "Voter already registered");

        Election storage election = elections[_electionId];
        Voter memory voter = Voter({
            registered: true,
            voted: false
        });

        election.voterList[_voterAddress] = voter;

        emit success("Voter registered");
    }

    function setVote(uint _electionId, address _candidateAddress) external {
        require(elections[_electionId].exists, "Election does not exist");
        require(elections[_electionId].voteInProgress, "Voting is not in progress");
        require(msg.sender != admin, "admin cannot vote");
        require(elections[_electionId].voterList[msg.sender].registered, "Voter not registered");
        require(!elections[_electionId].voterList[msg.sender].voted, "Already voted");
        require(elections[_electionId].candidateList[elections[_electionId].isCandidate[_candidateAddress]].registered, "Candidate not registered");

        Election storage election = elections[_electionId];
        election.candidateList[election.isCandidate[_candidateAddress]].votes++;
        election.voterList[msg.sender].voted = true;
        uint votes = election.candidateList[election.isCandidate[_candidateAddress]].votes;

        if(election.voteCount < votes) {
            election.voteCount = votes;
            election.winnerAddress = _candidateAddress;
        }

        emit success("Voted");
    }

    function setVotingState(uint _electionId, bool _isActive) external onlyAdmin {
        require(elections[_electionId].exists, "Election does not exist");

        elections[_electionId].voteInProgress = _isActive;

        if (_isActive) {
            emit success("Voting started");
        } else {
            emit success("Voting ended");
        }
    }

    function votingStatus(uint _electionId) external view returns (bool) {
        require(elections[_electionId].exists, "Election does not exist");
        return elections[_electionId].voteInProgress;
    }

    function getAllCandidates(uint _electionId) external view returns (Candidate[] memory) {
        require(elections[_electionId].exists, "Election does not exist");
        return elections[_electionId].candidateList;
    }

    function getWinner(uint _electionId) external view onlyAdmin returns (Candidate memory) {
        require(elections[_electionId].exists, "Election does not exist");
        return elections[_electionId].candidateList[elections[_electionId].isCandidate[elections[_electionId].winnerAddress]];
    }
}
