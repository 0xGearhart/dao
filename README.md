# Foundry DAO

A complete decentralized autonomous organization (DAO) implementation built with Solidity, enabling on-chain governance with voting, proposal queuing, and time-locked execution.

**⚠️ This project is not audited, use at your own risk**

## Table of Contents

- [Foundry DAO](#foundry-dao)
  - [Table of Contents](#table-of-contents)
  - [About](#about)
    - [Key Features](#key-features)
    - [Architecture](#architecture)
  - [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Quickstart](#quickstart)
    - [Environment Setup](#environment-setup)
  - [Usage](#usage)
    - [Overview of DAO Workflow](#overview-of-dao-workflow)
    - [Proposal Example: Changing DaoStorage State](#proposal-example-changing-daostorage-state)
    - [Build](#build)
    - [Testing](#testing)
    - [Test Coverage](#test-coverage)
    - [Deploy Locally](#deploy-locally)
    - [Interact with Contract](#interact-with-contract)
  - [Deployment](#deployment)
    - [Deploy to Testnet](#deploy-to-testnet)
    - [Verify Contract](#verify-contract)
    - [Deployment Addresses](#deployment-addresses)
  - [Security](#security)
    - [Audit Status](#audit-status)
    - [Access Control (Roles \& Permissions)](#access-control-roles--permissions)
    - [Known Limitations](#known-limitations)
  - [Gas Optimization](#gas-optimization)
  - [Contributing](#contributing)
  - [License](#license)

## About

Foundry DAO is a fully functional decentralized autonomous organization that leverages the OpenZeppelin governance framework to provide transparent, democratic decision-making on the blockchain. The DAO uses ERC20 voting tokens, a Governor contract for proposal management, and a TimeLock contract to ensure security through a mandatory execution delay.

### Key Features

- **ERC20 Governance Token** - Voting power based on token balance with delegation support
- **Democratic Proposal & Voting System** - Community-driven proposals with transparent voting
- **Time-Locked Execution** - Mandatory delay between proposal approval and execution for security
- **Configurable Governance Parameters** - Voting delay, voting period, quorum, and proposal thresholds
- **Full Test Coverage** - Comprehensive unit and integration tests
- **Production-Ready Scripts** - Deployment and interaction scripts for all networks

**Tech Stack:**
- Solidity ^0.8.27
- Foundry v1.11.0 (Forge, Cast, Anvil)
- OpenZeppelin Contracts v5.5.0
- foundry-devops v0.2.2 for deployment utilities

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   DAO Token Holders / Voters                    │
└──────────┬──────────────────────────────────────┬───────────────┘
           │                                      │
     delegate()                         propose() & vote()
           │                                      │
           ▼                                      ▼
     ┌────────────────┐                    ┌─────────────────┐
     │  DaoToken      │                    │   DaoGovernor   │
     │ (ERC20)        │                    │   (Governor)    │
     │                │                    │                 │
     │ - Voting Power │                    │ - Proposals     │
     │ - Transfer     │                    │ - Voting        │
     │ - Delegate     │                    │ - Queue         │
     └────────────────┘                    └─────┬───────────┘
                                                 │
                              (proposal approved by votes)
                                                 │
                                                 ▼
                            ┌────────────────────────────────┐
                            │      DaoTimeLock               │
                            │   (TimelockController)         │
                            │                                │
                            │ - Enforces minDelay (1 day)    │
                            │ - Permission control           │
                            │ - Proposes & Executes actions  │
                            └────────────┬───────────────────┘
                                         │
                         (executes after minDelay elapsed)
                                         │
                                         ▼
                            ┌────────────────────────────────┐
                            │      DaoStorage                │
                            │      (Ownable Contract)        │
                            │                                │
                            │ - changeNumber()               │
                            │ - onlyOwner (DaoTimeLock)      │
                            │ - State managed by DAO         │
                            └────────────────────────────────┘
```

**Repository Structure:**
```
foundry-dao/
├── src/
│   ├── DaoToken.sol          # ERC20 governance token with voting power
│   ├── DaoGovernor.sol       # Main governance contract for proposals and voting
│   ├── DaoTimeLock.sol       # Time lock for secure execution delays
│   └── DaoStorage.sol        # Example storage contract governed by DAO
├── script/
│   ├── DeployDao.s.sol       # Deployment script for all DAO contracts
│   ├── HelperConfig.s.sol    # Network configuration and constants
│   └── Interactions.s.sol    # Scripts for proposal/voting interactions
├── test/
│   ├── unit/
│   │   ├── DaoTokenTest.t.sol        # Token and voting tests
│   │   └── DaoStorageTest.t.sol      # Storage contract tests
│   └── integration/
│       ├── DaoTest.t.sol             # Full DAO workflow tests
│       ├── DeployDaoTest.t.sol       # Deployment tests
│       └── InteractionsTest.t.sol    # Interaction script tests
├── lib/                        # Dependencies
│   ├── forge-std/
│   ├── foundry-devops/
│   └── openzeppelin-contracts/
├── cache/                      # Cached build files
├── foundry.toml               # Foundry configuration
├── Makefile                   # Build and deployment commands
├── README.md                  # This file
└── .env.example              # Environment variables template
```

## Getting Started

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Verify installation: `git --version`
- [foundry](https://getfoundry.sh/)
  - Verify installation: `forge --version`

### Quickstart

```bash
git clone https://github.com/0xGearhart/foundry-dao
cd foundry-dao
make install
forge build
```

### Environment Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your `.env` file:**
   ```bash
   ETH_MAINNET_RPC_URL=your_eth_mainnet_rpc_url_here
   ETH_SEPOLIA_RPC_URL=your_eth_sepolia_rpc_url_here
   ARB_MAINNET_RPC_URL=your_arbitrum_mainnet_rpc_url_here
   ARB_SEPOLIA_RPC_URL=your_arbitrum_sepolia_rpc_url_here
   ETHERSCAN_API_KEY=your_etherscan_api_key_here
   DEFAULT_KEY_ADDRESS=public_address_of_your_encrypted_private_key_here
   ```

3. **Get testnet ETH:**
   - Sepolia Faucet: [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

4. **Configure Makefile**
- Change account name in Makefile to the name of your desired encrypted key 
  - change "--account defaultKey" to "--account <YOUR_ENCRYPTED_KEY_NAME>"
  - check encrypted key names stored locally with:

```bash
cast wallet list
```
- **If no encrypted keys found**
  - Encrypt private key to be used securely within foundry:

```bash
cast wallet import <account_name> --interactive
```

**⚠️ Security Warning:**
- Never commit your `.env` file
- Never use your mainnet private key for testing
- Use a separate wallet with only testnet funds

## Usage

### Overview of DAO Workflow

1. **Token Distribution** - Deployer receives initial DAO tokens
2. **Delegation** - Token holders delegate voting power to themselves or others
3. **Proposal Submission** - Token holders with sufficient voting power submit proposals
4. **Voting Period** - Community votes on the proposal (1 week by default)
5. **Queue & Execute** - If approved, proposal enters timelock, then can be executed (1 day delay minimum)
6. **Execution** - Proposal executes changes to governed contracts

### Proposal Example: Changing DaoStorage State

Here's a complete walkthrough of how a DAO proposal goes from submission to execution:

**Setup:**
- You have 100 DAO tokens
- Current value in DaoStorage: `0`
- Goal: Change it to `42`

**Step 1: Delegate Voting Power**
```bash
# Delegate to yourself (required to have voting power)
make delegate ARGS="--network eth sepolia"
```
- You now have voting power equal to your token balance
- This voting power is calculated from the block when the proposal was created

**Step 2: Submit Proposal**
```bash
# Submit proposal to change number to 42
make submit-proposal ARGS="--network eth sepolia"
```

Behind the scenes, this executes:
```solidity
// From Interactions.s.sol
address[] memory targets = [address(daoStorage)];
uint256[] memory values = [0];
bytes[] memory calldatas = [abi.encodeWithSignature("changeNumber(uint256)", 42)];
string memory description = "update number to 42";

daoGovernor.propose(targets, values, calldatas, description);
```

**Result:**
- Proposal is created with a unique `proposalId`
- Voting starts after `votingDelay` (1 day)
- Proposal ID can be obtained using:
```bash
cast call <DAO_GOVERNOR_ADDRESS> "getProposalId(address[],uint256[],bytes[],bytes32)" \
  "[<DAO_STORAGE_ADDRESS>]" "[0]" \
  "[0x4d33fed10000000000000000000000000000000000000000000000000000000000000000]" \
  "<DESCRIPTION_HASH>"
```

**Step 3: Vote on Proposal**
After voting delay, vote on the proposal:

```bash
# Vote "For" on the proposal
make vote ARGS="--network eth sepolia"
```

Behind the scenes:
```solidity
// From Interactions.s.sol
uint256 proposalId = daoGovernor.getProposalId(targets, values, calldatas, descriptionHash);
daoGovernor.castVoteWithReason(
    proposalId,
    uint8(GovernorCountingSimple.VoteType.For),  // 1 = For, 0 = Against, 2 = Abstain
    "The answer to life, the universe, and everything"
);
```

**Result:**
- Your 100 tokens are counted as "For" votes
- Other token holders can vote during the `votingPeriod` (1 week)
- Voting power is determined by the balance at the proposal creation block (snapshot)

**Step 4: Check Proposal Passed**
After voting period ends (7 days), check if proposal succeeded:

```bash
# Check proposal state
cast call <DAO_GOVERNOR_ADDRESS> "state(uint256)" "<PROPOSAL_ID>"
# Returns: 4 = Succeeded, 3 = Defeated

# View vote counts
cast call <DAO_GOVERNOR_ADDRESS> "proposalVotes(uint256)" "<PROPOSAL_ID>"
# Returns: [forVotes, againstVotes, abstainVotes]
```

**Step 5: Queue Proposal**
Queue the successful proposal for execution:

```bash
make queue-proposal ARGS="--network eth sepolia"
```

Behind the scenes:
```solidity
daoGovernor.queue(targets, values, calldatas, descriptionHash);
```

**Result:**
- Proposal moves to "Queued" state
- Timelock starts: proposal cannot execute for `minDelay` (1 day)
- During this period, community can exit the DAO if they disagree

**Step 6: Execute Proposal**
After minimum delay has elapsed (24 hours), execute the proposal:

```bash
make execute-proposal ARGS="--network eth sepolia"
```

Behind the scenes:
```solidity
daoGovernor.execute(targets, values, calldatas, descriptionHash);
```

This calls:
```solidity
// DaoStorage.changeNumber(42) is invoked
// onlyOwner modifier checks that msg.sender == owner
// owner is set to address(daoTimeLock)
// DaoTimeLock calls changeNumber, so the check passes
s_number = 42;
emit NumberChanged(42);
```

**Step 7: Verify Execution**
Confirm the state change:

```bash
# Check the new value
cast call <DAO_STORAGE_ADDRESS> "getNumber()"
# Returns: 42 (in hex: 0x000000000000000000000000000000000000000000000000000000000000002a)
```

**Timeline Summary:**
| Phase                 | Duration                | What Happens                                  |
| --------------------- | ----------------------- | --------------------------------------------- |
| Pending               | `votingDelay` (1 day)   | Proposal created, waiting for voting to start |
| Active                | `votingPeriod` (1 week) | Community votes                               |
| Defeated or Succeeded | -                       | Voting ended                                  |
| Queued                | -                       | Proposal queued for execution                 |
| Timelocked            | `minDelay` (1 day)      | Waiting before execution allowed              |
| Executed              | -                       | Proposal executed on target contract          |

**Total Time:** ~9 days minimum from proposal to execution (1 day delay + 7 day voting + 1 day timelock)

### Build

Compile the contracts:

```bash
forge build
```

### Testing

Run the test suite:

```bash
forge test
```

Run tests with verbosity:

```bash
forge test -vvv
```

Run specific test:

```bash
forge test --match-test testFunctionName
```

### Test Coverage

Generate coverage report:

```bash
forge coverage
```

### Deploy Locally

Start a local Anvil node:

```bash
make anvil
```

Deploy to local node (in another terminal):

```bash
make deploy
```

### Interact with Contract

**Delegate voting power to yourself:**
```bash
make delegate ARGS="--network eth sepolia"
```

**Submit a proposal:**
```bash
make submit-proposal ARGS="--network eth sepolia"
```

**Vote on a proposal:**
```bash
make vote ARGS="--network eth sepolia"
```

**Queue an approved proposal:**
```bash
make queue-proposal ARGS="--network eth sepolia"
```

**Execute a queued proposal (after timelock delay):**
```bash
make execute-proposal ARGS="--network eth sepolia"
```

**View proposal details using cast:**
```bash
# Get proposal ID
cast call <DAO_GOVERNOR_ADDRESS> "getProposalId(address[],uint256[],bytes[],bytes32)" "[<TARGET>]" "[0]" "[<CALLDATA>]" "<DESCRIPTION_HASH>"

# Check proposal state
cast call <DAO_GOVERNOR_ADDRESS> "state(uint256)" "<PROPOSAL_ID>"

# Get votes received
cast call <DAO_GOVERNOR_ADDRESS> "proposalVotes(uint256)" "<PROPOSAL_ID>"
```

## Deployment

### Deploy to Testnet

Deploy to Ethereum Sepolia:

```bash
make deploy ARGS="--network eth sepolia"
```

Deploy to Arbitrum Sepolia:

```bash
make deploy ARGS="--network arb sepolia"
```

Or using forge directly:

```bash
forge script script/DeployDao.s.sol:DeployDao --rpc-url $ETH_SEPOLIA_RPC_URL --account defaultKey --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

### Verify Contract

If automatic verification fails:

```bash
# Sepolia
forge verify-contract <CONTRACT_ADDRESS> src/DaoToken.sol:DaoToken --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY

# Arbitrum Sepolia
forge verify-contract <CONTRACT_ADDRESS> src/DaoGovernor.sol:DaoGovernor --chain-id 421614 --etherscan-api-key $ETHERSCAN_API_KEY
```

### Deployment Addresses

| Network          | Contract    | Address | Explorer                                          |
| ---------------- | ----------- | ------- | ------------------------------------------------- |
| Sepolia          | DaoToken    | `TBD`   | [View on Etherscan](https://sepolia.etherscan.io) |
| Sepolia          | DaoGovernor | `TBD`   | [View on Etherscan](https://sepolia.etherscan.io) |
| Sepolia          | DaoTimeLock | `TBD`   | [View on Etherscan](https://sepolia.etherscan.io) |
| Sepolia          | DaoStorage  | `TBD`   | [View on Etherscan](https://sepolia.etherscan.io) |
| Arbitrum Sepolia | DaoToken    | `TBD`   | [View on Arbiscan](https://sepolia.arbiscan.io)   |
| Arbitrum Sepolia | DaoGovernor | `TBD`   | [View on Arbiscan](https://sepolia.arbiscan.io)   |
| Arbitrum Sepolia | DaoTimeLock | `TBD`   | [View on Arbiscan](https://sepolia.arbiscan.io)   |
| Arbitrum Sepolia | DaoStorage  | `TBD`   | [View on Arbiscan](https://sepolia.arbiscan.io)   |

## Security

### Audit Status

⚠️ **This contract has not been audited.** Use at your own risk.

For production use, consider:
- Professional security audit
- Bug bounty program
- Gradual rollout with monitoring

### Access Control (Roles & Permissions)

The DAO implements OpenZeppelin's `TimelockController` for role-based access control with the following roles:

**Core Roles (defined in DaoTimeLock):**

- **`DEFAULT_ADMIN_ROLE` (0x00)**
  - Granted to: Deployer (immediately revoked after setup to prevent centralization)
  - Permissions: Grant/revoke other roles
  - Note: This role is renounced during deployment to ensure decentralization

- **`PROPOSER_ROLE` (keccak256("PROPOSER_ROLE"))**
  - Granted to: `DaoGovernor` contract only
  - Permissions: Submit proposals to the timelock
  - Only the DAO Governor can propose execution of transactions
  - Prevents unauthorized addresses from queuing operations

- **`EXECUTOR_ROLE` (keccak256("EXECUTOR_ROLE"))**
  - Granted to: `address(0)` (anyone can execute)
  - Permissions: Execute queued proposals after minimum delay
  - Allows permissionless execution of approved proposals
  - Enforces the `minDelay` time lock between approval and execution

**DaoStorage Contract:**

- **`Ownable` pattern** 
  - Owner: `DaoTimeLock` contract
  - Permissions: `changeNumber()` function (can only be called by owner)
  - State changes to the DAO-governed contract must go through the governance process

**Governance Parameters (DaoGovernor):**

| Parameter             | Value  | Purpose                                                                                  |
| --------------------- | ------ | ---------------------------------------------------------------------------------------- |
| `votingDelay`         | 1 day  | Delay between proposal submission and voting start                                       |
| `votingPeriod`        | 1 week | Duration of the voting period                                                            |
| `proposalThreshold`   | 0      | Minimum voting power required to submit a proposal (0 = any submitted proposal is valid) |
| `quorumNumerator`     | 10%    | Percentage of total supply needed for quorum                                             |
| `minDelay` (TimeLock) | 1 day  | Minimum delay before execution of approved proposals                                     |

**Access Control Diagram:**

```
External Users (EOAs)
        │
        ├─→ Can delegate voting power
        ├─→ Can vote on proposals (if delegated)
        └─→ Can submit proposals (if delegated)
                │
                ▼
        DaoGovernor (Governor)
                │
                ├─→ PROPOSER_ROLE to DaoTimeLock
                └─→ Proposal approved by votes
                        │
                        ▼
                DaoTimeLock (TimelockController)
                │
                ├─→ Enforces minDelay (1 day)
                │
                ├─→ EXECUTOR_ROLE = address(0)
                │   (anyone can execute after delay)
                │
                └─→ DaoStorage contract
                        │
                        └─→ changeNumber() - onlyOwner
                            (owner = DaoTimeLock)
```

**Vulnerability Mitigations:**

✅ **Role Separation**: PROPOSER and EXECUTOR roles are separated and controlled by the Governor and permissionless execution, respectively.

✅ **Timelock Delay**: All state changes go through a mandatory 1-day delay, allowing users to exit if they disagree.

✅ **Decentralized Admin**: The DEFAULT_ADMIN_ROLE is revoked during deployment, removing centralized control.

✅ **Voting Power Snapshots**: Voting power is based on historical token balances, preventing flash loan attacks.

⚠️ **Consideration**: The quorum requirement (10%) should be monitored to ensure healthy participation levels.

### Known Limitations

- **No proposal veto mechanism** - Once a proposal passes voting and timelock delay, it will execute without additional checks
- **Quorum requirement is percentage-based** - If token distribution becomes too concentrated, quorum may become too easy to reach
- **No upgrade mechanism** - Governance contracts cannot be upgraded; any changes require new deployments
- **Single example contract** - DaoStorage is a simple example; real DAO would govern more critical systems

**Centralization Risks:**

- The deployer initially controls all tokens, but this can be mitigated by distributing tokens fairly
- The deployer nominates the initial timelock admin role, which is immediately revoked

**External Dependencies:**

- OpenZeppelin Contracts library (v5.5.0) - thoroughly audited and battle-tested

## Gas Optimization

The DAO implementation uses OpenZeppelin's optimized governance contracts. Key gas-efficient design patterns:

- **Vote delegation** - Voting power is delegated by users themselves (not assigned by contract)
- **Governor storage extension** - Efficiently stores proposal details with minimal redundancy
- **Batch operations** - Proposals support multiple target contracts in a single proposal

**Function Gas Estimates:**

| Function               | Approx. Gas Cost |
| ---------------------- | ---------------- |
| `delegate()`           | ~95,542          |
| `propose()`            | ~293,094         |
| `castVoteWithReason()` | ~84,650          |
| `queue()`              | ~144,503         |
| `execute()`            | ~112,000         |

Generate gas report:

```bash
make gas-report
```

Generate gas snapshot:

```bash
make snapshot
```

Compare gas changes:

```bash
forge snapshot --diff
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Disclaimer:** This software is provided "as is", without warranty of any kind. Use at your own risk.

**Built with [Foundry](https://getfoundry.sh/)**