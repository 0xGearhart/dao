// SPDX-License-Identifier: MIT

import {Script, console2} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

contract CodeConstants {
    string constant TOKEN_NAME = "DaoToken";
    string constant TOKEN_SYMBOL = "DAO";
    uint256 constant INITIAL_SUPPLY = 1000 ether;

    string constant GOVERNOR_NAME = "DaoGovernor";
    uint48 constant VOTING_DELAY = 1 days; // delay between when a proposal is submitted and voting begins
    uint32 constant VOTING_PERIOD = 1 weeks; // amount of time a vote is open for
    uint256 constant PROPOSAL_VOTING_THRESHOLD = 0; // amount of votes to make a proposal active (0 means any submitted proposal is valid)
    uint256 constant QUORUM_NUMERATOR_VALUE = 10; // percent of votes needed for a quorum to be reached

    uint256 constant MIN_DELAY = 1 days;

    uint256 constant LOCAL_CHAIN_ID = 31_337;
    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11_155_111;
    uint256 constant ARB_MAINNET_CHAIN_ID = 42_161;
    uint256 constant ARB_SEPOLIA_CHAIN_ID = 421_614;
}

contract HelperConfig is Script, CodeConstants {
    struct NetworkConfig {
        address account;
    }

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        if (block.chainid == LOCAL_CHAIN_ID) {
            return NetworkConfig({account: DEFAULT_SENDER});
        } else {
            return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS")});
        }
    }
}
