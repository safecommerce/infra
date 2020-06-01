pragma solidity ^0.6.8;

import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "../votingMachines/VotingMachineCallbacksInterface.sol";
import "../votingMachines/ProposalExecuteInterface.sol";
import "../votingMachines/GenesisProtocol.sol";
import "../Reputation.sol";
import "./Debug.sol";


contract GenesisProtocolCallbacksMock is Debug, VotingMachineCallbacksInterface,
                                            ProposalExecuteInterface, OwnableUpgradeSafe {

    Reputation public reputation;
    IERC20 public stakingToken;
    GenesisProtocol public genesisProtocol;
    mapping (bytes32=>uint) public proposalsBlockNumbers;

    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer
    );

    /**
    * @dev initialize
    */
    function initialize(Reputation _reputation, IERC20 _stakingToken, GenesisProtocol _genesisProtocol)
    external
    initializer {
        reputation = _reputation;
        stakingToken = _stakingToken;
        genesisProtocol = _genesisProtocol;
        __Ownable_init_unchained();
        transferOwnership(address(_genesisProtocol));
    }

    function mintReputation(uint256 _amount, address _beneficiary, bytes32)
    external
    onlyOwner
    override
    returns(bool)
    {
        return reputation.mint(_beneficiary, _amount);
    }

    function burnReputation(uint256 _amount, address _beneficiary, bytes32)
    external
    onlyOwner
    override
    returns(bool)
    {
        return reputation.burn(_beneficiary, _amount);
    }

    function stakingTokenTransfer(IERC20 _stakingToken, address _beneficiary, uint256 _amount, bytes32)
    external
    onlyOwner
    override
    returns(bool)
    {
        return _stakingToken.transfer(_beneficiary, _amount);
    }

    function executeProposal(bytes32 _proposalId, int _decision) external override returns(bool) {
        emit LogBytes32(_proposalId);
        emit LogInt(_decision);
        return true;
    }

    function propose(uint256 _numOfChoices, address _proposer)
    external
    returns
    (bytes32)
    {
        bytes32 proposalId = genesisProtocol.propose(_numOfChoices, _proposer);
        emit NewProposal(proposalId, address(this), _numOfChoices, _proposer);
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

    function getTotalReputationSupply(bytes32 _proposalId) external view override returns(uint256) {
        return reputation.totalSupplyAt(proposalsBlockNumbers[_proposalId]);
    }

    function balanceOfStakingToken(IERC20 _stakingToken, bytes32)
    external
    view
    override
    returns(uint256)
    {
        return _stakingToken.balanceOf(address(this));
    }

    function reputationOf(address _owner, bytes32 _proposalId) external view override returns(uint256) {
        return reputation.balanceOfAt(_owner, proposalsBlockNumbers[_proposalId]);
    }

}
