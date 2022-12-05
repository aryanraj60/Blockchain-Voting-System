//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

error Not_Organizer();

//Voters
error Voter_Is_Not_Registered();
error Voter_Is_Already_Allowed();
error You_Are_Not_Approved_To_Vote();
error You_Already_Voted();
error You_Already_Registered();

//Candidates
error Candidate_Is_Not_Registered();
error Wrong_Candidate_Id();
error Candidate_Is_Already_Registered();

contract VotingSystem {
    //Candidate and Voter Id's
    using Counters for Counters.Counter;
    Counters.Counter private s_canidateIds;
    Counters.Counter private s_voterIds;

    //ELECTION's Organizer
    address private s_organizer;

    constructor() {
        s_organizer = msg.sender;
    }

    //ENUMS
    enum ElectionState {
        RegistrationPhase,
        VotingPhase,
        ElectionsEndPhase,
        WinnerDeclaredPhase
    }

    ElectionState private s_electionState;

    //CANDIDATE
    struct CANDIDATE {
        address candidateAddress;
        string candidateName;
        string candidatePartyName;
        uint256 candidateId;
        uint256 totalVotes;
        string candidateImage;
    }

    //CANDIDATE DATA STRUCTURES

    mapping(address => CANDIDATE) private s_candidates;

    address[] private s_candidateAddresses;

    //CANDIDATE EVENTS
    event CandidateAdded(
        address candidateAddress,
        string candidateName,
        string candidatePartyName,
        uint256 candidateId,
        uint256 totalVotes,
        string candidateImage
    );

    //VOTERS
    struct VOTER {
        address voterAddress;
        string voterName;
        uint256 voterId;
        uint256 voterVotedTo;
        bool isVoted;
        bool isVoterAllowed;
        string voterImage;
    }

    mapping(address => VOTER) private s_voters;

    address[] private s_votersAddresses;
    address[] private s_approvedVotersAddresses;
    address[] private s_votedVotersAddress;

    //VOTERS EVENTS
    event VoterRegistered(
        address voterAddress,
        string voterName,
        uint256 voterId,
        uint256 voterVotedTo,
        bool isVoted,
        bool isVoterAllowed,
        string voterImage
    );
    event VoterApproved(address approvedVoterAddress, uint256 approvedVoterId);
    event SuccessfullyVoted(
        address candidateAddress,
        uint256 candidateId,
        address voterAddress,
        uint256 voterId
    );

    //Winner STRUCT After Winner Declaration
    CANDIDATE private s_winnerCandidate;
    address[] private s_winnersAddresses;
    event WinnerDeclared(address _candidateAddress, uint256 _candidateId);

    //Modifier
    modifier onlyOrganizer(address _organizer) {
        if (_organizer != s_organizer) {
            revert Not_Organizer();
        }
        _;
    }

    modifier registrationPhase() {
        require(
            s_electionState == ElectionState.RegistrationPhase,
            "Registraions are closed Currently!"
        );
        _;
    }

    modifier votingPhase() {
        require(
            s_electionState == ElectionState.VotingPhase,
            "Voting is Closed Currently!"
        );
        _;
    }

    modifier electionEndPhase() {
        require(
            s_electionState == ElectionState.ElectionsEndPhase,
            "Elections are not Ended Yet!"
        );
        _;
    }

    //FUNCTIONS

    //Registraion Phase
    //Candidate Registration

    function addCandidate(
        address _candidateAddress,
        string memory _candidateName,
        string memory _candidatePartyName,
        string memory _candidateImage
    ) external onlyOrganizer(msg.sender) registrationPhase {
        CANDIDATE storage candidate = s_candidates[_candidateAddress];
        if (candidate.candidateId != 0) {
            revert Candidate_Is_Already_Registered();
        }

        s_canidateIds.increment();
        uint256 _candidateId = s_canidateIds.current();

        candidate.candidateAddress = _candidateAddress;
        candidate.candidateName = _candidateName;
        candidate.candidatePartyName = _candidatePartyName;
        candidate.candidateId = _candidateId;
        candidate.totalVotes = 0;
        candidate.candidateImage = _candidateImage;

        s_candidateAddresses.push(_candidateAddress);

        emit CandidateAdded(
            _candidateAddress,
            _candidateName,
            _candidatePartyName,
            _candidateId,
            candidate.totalVotes,
            _candidateImage
        );
    }

    //Voters Registration

    function voterRegister(
        string memory _voterName,
        string memory _voterImage
    ) external registrationPhase {
        VOTER storage voter = s_voters[msg.sender];

        if (voter.isVoted) {
            revert You_Already_Voted();
        }

        if (voter.voterId != 0) {
            revert You_Already_Registered();
        }

        s_voterIds.increment();
        uint256 _voterId = s_voterIds.current();

        voter.voterAddress = msg.sender;
        voter.voterName = _voterName;
        voter.voterId = _voterId;
        voter.voterVotedTo = 0;
        voter.isVoted = false;
        voter.isVoterAllowed = false;
        voter.voterImage = _voterImage;

        s_votersAddresses.push(msg.sender);

        emit VoterRegistered(
            msg.sender,
            _voterName,
            _voterId,
            voter.voterVotedTo,
            voter.isVoted,
            voter.isVoterAllowed,
            _voterImage
        );
    }

    //Giving Approval to Voter

    function approveVoter(
        address _voterAddress
    ) external onlyOrganizer(msg.sender) {
        VOTER storage voter = s_voters[_voterAddress];
        if (voter.voterId == 0) {
            revert Voter_Is_Not_Registered();
        }
        if (voter.isVoterAllowed) {
            revert Voter_Is_Already_Allowed();
        }

        voter.isVoterAllowed = true;

        s_approvedVotersAddresses.push(_voterAddress);

        emit VoterApproved(_voterAddress, voter.voterId);
    }

    //Start voting Phase
    function startVotingPhase() external onlyOrganizer(msg.sender) {
        require(
            s_electionState != ElectionState.VotingPhase,
            "Voting phase is already active"
        );
        require(
            s_electionState == ElectionState.RegistrationPhase,
            "Current phase should be registraion to start voting"
        );
        s_electionState = ElectionState.VotingPhase;
    }

    //Voting Functions

    function vote(
        address _candidateAddress,
        uint256 _candidateId
    ) external votingPhase {
        VOTER storage voter = s_voters[msg.sender];
        if (voter.voterId == 0) {
            revert Voter_Is_Not_Registered();
        }
        if (!voter.isVoterAllowed) {
            revert You_Are_Not_Approved_To_Vote();
        }
        if (voter.isVoted) {
            revert You_Already_Voted();
        }

        CANDIDATE storage candidate = s_candidates[_candidateAddress];
        if (candidate.candidateId == 0) {
            revert Candidate_Is_Not_Registered();
        }
        if (candidate.candidateId != _candidateId) {
            revert Wrong_Candidate_Id();
        }

        candidate.totalVotes += 1;
        voter.voterVotedTo = _candidateId;
        voter.isVoted = true;

        s_votedVotersAddress.push(msg.sender);

        emit SuccessfullyVoted(
            candidate.candidateAddress,
            candidate.candidateId,
            voter.voterAddress,
            voter.voterId
        );
    }

    //Election EndPhase
    function setElectionEndPhase() external onlyOrganizer(msg.sender) {
        require(
            s_electionState != ElectionState.ElectionsEndPhase,
            "Elections are already ended!"
        );
        require(
            s_electionState == ElectionState.VotingPhase,
            "Current phase should be voting to end elections!"
        );
        s_electionState = ElectionState.ElectionsEndPhase;
    }

    function generateRandomNumber(
        uint256 _winners
    ) private view returns (uint256) {
        uint256 number = uint(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, _winners)
            )
        );
        uint256 index = number % _winners;
        return index;
    }

    function calculateMaximumVotes() private view returns (uint256) {
        uint256 maxVotes;

        for (uint256 i = 0; i < s_candidateAddresses.length; i++) {
            CANDIDATE memory candidate = s_candidates[s_candidateAddresses[i]];
            if (candidate.totalVotes > maxVotes) {
                maxVotes = candidate.totalVotes;
            }
        }

        return maxVotes;
    }

    function calculateWinner() private {
        uint256 maxVoteCounts = calculateMaximumVotes();
        console.log(maxVoteCounts);

        for (uint256 i = 0; i < s_candidateAddresses.length; i++) {
            CANDIDATE memory candidate = s_candidates[s_candidateAddresses[i]];
            console.log(
                "Selected Candidate Address",
                candidate.candidateAddress
            );
            // console.log("WinnerIndex inside loop", winnerIndex);
            if (candidate.totalVotes == maxVoteCounts) {
                s_winnersAddresses.push(candidate.candidateAddress);
                console.log("s_winnersAddress state updated");
            }
        }
    }

    function declareWinner()
        external
        onlyOrganizer(msg.sender)
        electionEndPhase
    {
        require(s_votedVotersAddress.length != 0, "No voter Voted Yet");
        require(
            s_candidateAddresses.length != 0,
            "There is no candidate in the elections yet!"
        );
        address winnerAddress;
        console.log("Intial winner", winnerAddress);
        //Calculating and Saving Winners to the state
        calculateWinner();
        //Getting winners addresses from the state
        address[] memory _winnerCandidateAddresses = s_winnersAddresses;
        console.log("total winners", _winnerCandidateAddresses.length);
        //Checking if there is more than one winner
        if (_winnerCandidateAddresses.length > 1) {
            uint256 randomIndex = generateRandomNumber(
                _winnerCandidateAddresses.length
            );
            console.log("Random Index", randomIndex);
            winnerAddress = _winnerCandidateAddresses[randomIndex];
        } else {
            winnerAddress = _winnerCandidateAddresses[0];
        }

        console.log("final winner address", winnerAddress);
        CANDIDATE memory _winnerCandidate = s_candidates[winnerAddress];
        s_winnerCandidate = _winnerCandidate;
        s_electionState = ElectionState.WinnerDeclaredPhase;

        emit WinnerDeclared(
            s_winnerCandidate.candidateAddress,
            s_winnerCandidate.candidateId
        );
    }

    //Getter Functions

    function getTotalCandidates() public view returns (uint256) {
        return s_canidateIds.current();
    }

    function getTotalVoters() public view returns (uint256) {
        return s_voterIds.current();
    }

    function getOrganizer() public view returns (address) {
        return s_organizer;
    }

    function getElectionPhase() public view returns (ElectionState) {
        return s_electionState;
    }

    //Candidate

    function getCandidate(
        address _candidateAddress
    ) public view returns (CANDIDATE memory) {
        return s_candidates[_candidateAddress];
    }

    function getCandidateAddresses() public view returns (address[] memory) {
        return s_candidateAddresses;
    }

    //Voter

    function getVoter(
        address _voterAddress
    ) public view returns (VOTER memory) {
        return s_voters[_voterAddress];
    }

    function getRegisteredVoters() public view returns (address[] memory) {
        return s_votersAddresses;
    }

    function getApprovedVoters() public view returns (address[] memory) {
        return s_approvedVotersAddresses;
    }

    function getVotedVoters() public view returns (address[] memory) {
        return s_votedVotersAddress;
    }

    //Winner

    function getWinnersAddresses() public view returns (address[] memory) {
        return s_winnersAddresses;
    }

    function getWinner() public view returns (CANDIDATE memory) {
        return s_winnerCandidate;
    }
}
