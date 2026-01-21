// SPDX-License-Identifier: MIT

import {DaoGovernor, GovernorCountingSimple} from "../src/DaoGovernor.sol";
import {DaoToken} from "../src/DaoToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";

pragma solidity 0.8.33;

contract InteractionsData {
    // addresses
    DaoToken daoToken = DaoToken(address(0));
    DaoGovernor daoGovernor = DaoGovernor(payable(address(0)));
    address daoStorage = address(0);

    // proposal data
    uint256 newNumber = 42;
    bytes encodedFunctionCall = abi.encodeWithSignature("changeNumber(uint256)", newNumber);
    string description = "update number to 42";
    bytes32 descriptionHash = keccak256(abi.encodePacked(description));
    address[] targets;
    uint256[] values;
    bytes[] calldatas;

    // vote data
    string reason = "The answer to life, the universe, and everything";
    uint8 vote = uint8(GovernorCountingSimple.VoteType.For);
}

contract Delegate is Script, InteractionsData {
    function run(address _daoToken) external {
        daoToken = DaoToken(_daoToken);

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // delegate voting power to self
        vm.startBroadcast(config.account);
        daoToken.delegate(config.account);
        vm.stopBroadcast();
    }
}

contract SubmitProposal is Script, InteractionsData {
    function run(address _daoStorage, address _daoGovernor) external {
        daoStorage = _daoStorage;
        daoGovernor = DaoGovernor((payable(_daoGovernor)));

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // proposal data
        targets.push(daoStorage);
        values.push(0);
        calldatas.push(encodedFunctionCall);

        // send proposal to the DAO
        vm.startBroadcast(config.account);
        daoGovernor.propose(targets, values, calldatas, description);
        vm.stopBroadcast();
    }
}

contract Vote is Script, InteractionsData {
    function run(address _daoStorage, address _daoGovernor) external {
        daoStorage = _daoStorage;
        daoGovernor = DaoGovernor((payable(_daoGovernor)));

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // proposal data
        targets.push(daoStorage);
        values.push(0);
        calldatas.push(encodedFunctionCall);

        // vote yes on submitted proposal
        vm.startBroadcast(config.account);
        uint256 proposalId = daoGovernor.getProposalId(targets, values, calldatas, descriptionHash);
        daoGovernor.castVoteWithReason(proposalId, vote, reason);
        vm.stopBroadcast();
    }
}

contract QueueProposal is Script, InteractionsData {
    function run(address _daoStorage, address _daoGovernor) external {
        daoStorage = _daoStorage;
        daoGovernor = DaoGovernor((payable(_daoGovernor)));

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // proposal data
        targets.push(daoStorage);
        values.push(0);
        calldatas.push(encodedFunctionCall);

        // queue successful proposal
        vm.startBroadcast(config.account);
        daoGovernor.queue(targets, values, calldatas, descriptionHash);
        vm.stopBroadcast();
    }
}

contract ExecuteProposal is Script, InteractionsData {
    function run(address _daoStorage, address _daoGovernor) external {
        daoStorage = _daoStorage;
        daoGovernor = DaoGovernor((payable(_daoGovernor)));

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // proposal data
        targets.push(daoStorage);
        values.push(0);
        calldatas.push(encodedFunctionCall);

        // execute queued proposal
        vm.startBroadcast(config.account);
        daoGovernor.execute(targets, values, calldatas, descriptionHash);
        vm.stopBroadcast();
    }
}
