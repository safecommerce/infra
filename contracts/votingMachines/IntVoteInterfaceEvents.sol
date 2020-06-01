pragma solidity ^0.6.8;


interface IntVoteInterfaceEvents {
    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer
    );

    event ExecuteProposal(bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _decision,
        uint256 _totalReputation
    );

    event VoteProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _voter,
        uint256 _vote,
        uint256 _reputation
    );
}