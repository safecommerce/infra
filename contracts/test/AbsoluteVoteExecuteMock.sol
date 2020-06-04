pragma solidity ^0.5.17;

import "../votingMachines/ProposalExecuteInterface.sol";
import "../votingMachines/VotingMachineCallbacksInterface.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "./Debug.sol";
import "../Reputation.sol";
import "../votingMachines/AbsoluteVote.sol";


contract AbsoluteVoteExecuteMock is Debug, VotingMachineCallbacksInterface, ProposalExecuteInterface, Ownable {

    Reputation public reputation;
    AbsoluteVote public absoluteVote;
    mapping (bytes32=>uint) public proposalsBlockNumbers;

    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer,
        bytes32 _paramsHash
    );

    /**
    * @dev initialize
    */
    function initialize(Reputation _reputation, AbsoluteVote _absoluteVote)
    external
    initializer {
        reputation = _reputation;
        absoluteVote = _absoluteVote;
        Ownable.initialize(address(_absoluteVote));
    }

    function mintReputation(uint256 _amount, address _beneficiary, bytes32)
    public
    onlyOwner
    returns(bool)
    {
        return reputation.mint(_beneficiary, _amount);
    }

    function burnReputation(uint256 _amount, address _beneficiary, bytes32)
    public
    onlyOwner
    returns(bool)
    {
        return reputation.burn(_beneficiary, _amount);
    }

    function stakingTokenTransfer(IERC20 _stakingToken, address _beneficiary, uint256 _amount, bytes32)
    public
    onlyOwner
    returns(bool)
    {
        return _stakingToken.transfer(_beneficiary, _amount);
    }

    function executeProposal(bytes32 _proposalId, int _decision) external returns(bool) {
        emit LogBytes32(_proposalId);
        emit LogInt(_decision);
        return true;
    }

    function propose(uint256 _numOfChoices, address _proposer)
    external
    returns
    (bytes32)
    {
        bytes32 proposalId = absoluteVote.propose(_numOfChoices, _proposer);
        proposalsBlockNumbers[proposalId] = block.number;

        return proposalId;
    }

    //this function is used only for testing purpose on this mock contract
    function burnReputationTest(uint256 _amount, address _beneficiary, bytes32)
    external
    returns(bool)
    {
        return reputation.burn(_beneficiary, _amount);
    }

    function setProposal(bytes32 _proposalId) external returns(bool) {
        proposalsBlockNumbers[_proposalId] = block.number;
    }

    function getTotalReputationSupply(bytes32 _proposalId) public view returns(uint256) {
        return reputation.totalSupplyAt(proposalsBlockNumbers[_proposalId]);
    }

    function reputationOf(address _owner, bytes32 _proposalId) public view returns(uint256) {
        return reputation.balanceOfAt(_owner, proposalsBlockNumbers[_proposalId]);
    }

    function balanceOfStakingToken(IERC20 _stakingToken, bytes32)
    public
    view
    returns(uint256)
    {
        return _stakingToken.balanceOf(address(this));
    }

}
