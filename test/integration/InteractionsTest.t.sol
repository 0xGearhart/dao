// SPDX-License-Identifier: MIT

import {DeployDao} from "../../script/DeployDao.s.sol";
import {CodeConstants, HelperConfig} from "../../script/HelperConfig.s.sol";
import {Delegate, ExecuteProposal, QueueProposal, SubmitProposal, Vote} from "../../script/Interactions.s.sol";
import {DaoGovernor} from "../../src/DaoGovernor.sol";
import {DaoStorage} from "../../src/DaoStorage.sol";
import {DaoTimeLock} from "../../src/DaoTimeLock.sol";
import {DaoToken} from "../../src/DaoToken.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract InteractionsTest is Test, CodeConstants {
    DeployDao public deployDao;
    DaoGovernor public daoGovernor;
    DaoToken public daoToken;
    DaoStorage public daoStorage;
    DaoTimeLock public daoTimeLock;

    uint256 public newNumber = 42;
    address user = makeAddr("user");

    function setUp() public {
        deployDao = new DeployDao();
        (daoTimeLock, daoGovernor, daoToken, daoStorage) = deployDao.run();
    }

    function testDelegateScript() public {
        Delegate delegate = new Delegate();
        delegate.run(address(daoToken));
    }

    function testSubmitProposalScript() public {
        SubmitProposal submitProposal = new SubmitProposal();
        submitProposal.run(address(daoStorage), address(daoGovernor));
    }

    function testVoteScript() public {
        Delegate delegate = new Delegate();
        delegate.run(address(daoToken));
        SubmitProposal submitProposal = new SubmitProposal();
        submitProposal.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + VOTING_DELAY + 1);

        Vote vote = new Vote();
        vote.run(address(daoStorage), address(daoGovernor));
    }

    function testQueueProposalScript() public {
        Delegate delegate = new Delegate();
        delegate.run(address(daoToken));
        SubmitProposal submitProposal = new SubmitProposal();
        submitProposal.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        Vote vote = new Vote();
        vote.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + VOTING_PERIOD + 1);

        QueueProposal queueProposal = new QueueProposal();
        queueProposal.run(address(daoStorage), address(daoGovernor));
    }

    function testExecuteProposalScript() public {
        Delegate delegate = new Delegate();
        delegate.run(address(daoToken));
        SubmitProposal submitProposal = new SubmitProposal();
        submitProposal.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        Vote vote = new Vote();
        vote.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        QueueProposal queueProposal = new QueueProposal();
        queueProposal.run(address(daoStorage), address(daoGovernor));
        vm.warp(block.timestamp + MIN_DELAY + 1);

        ExecuteProposal executeProposal = new ExecuteProposal();
        executeProposal.run(address(daoStorage), address(daoGovernor));

        assertEq(daoStorage.getNumber(), newNumber);
    }
}
