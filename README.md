# ProgramVote

**A decentralized voting system smart contract for academic program approval on the Stacks blockchain**

ProgramVote is a Clarity smart contract that enables secure, transparent, and decentralized voting for academic program proposals. Built on the Stacks blockchain, it provides a robust framework for educational institutions to manage program approvals through a democratic voting process.

## 🚀 Features

- **Authorized Voter Management**: Contract owner can add/remove authorized voters
- **Proposal Creation**: Authorized voters can create detailed program proposals
- **Secure Voting**: One vote per voter per proposal with time-bound voting periods
- **Automatic Finalization**: Proposals are automatically approved/rejected based on vote outcomes
- **Transparency**: All votes and proposals are recorded on-chain
- **Status Tracking**: Real-time proposal status monitoring (Active, Approved, Rejected)
- **Comprehensive Error Handling**: Detailed error codes for better debugging

## 🛠 Technical Specifications

- **Blockchain**: Stacks (STX)
- **Smart Contract Language**: Clarity v2
- **Epoch**: 2.5
- **Contract Version**: 1.0.0
- **Test Framework**: Vitest with Clarinet SDK

### Contract Architecture

```
├── Data Variables
│   └── next-proposal-id (tracks proposal IDs)
├── Data Maps
│   ├── authorized-voters (principal → bool)
│   ├── proposals (uint → proposal-data)
│   └── votes ({proposal-id, voter} → bool)
└── Functions
    ├── Public Functions (8)
    ├── Read-Only Functions (5)
    └── Error Constants (6)
```

## 📦 Installation

### Prerequisites

- [Node.js](https://nodejs.org/) (v16 or higher)
- [Clarinet](https://github.com/hirosystems/clarinet) (latest version)
- [Git](https://git-scm.com/)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ProgramVote
   ```

2. **Navigate to contract directory**
   ```bash
   cd ProgramVote_contract
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Verify installation**
   ```bash
   clarinet check
   ```

## 🚀 Usage Examples

### Initialize Contract
```clarity
;; Initialize the contract (sets deployer as authorized voter)
(contract-call? .ProgramVote initialize)
```

### Add Authorized Voter
```clarity
;; Only contract owner can add voters
(contract-call? .ProgramVote add-authorized-voter 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Create a Proposal
```clarity
;; Create a new program proposal with 1000 block voting period
(contract-call? .ProgramVote create-proposal 
  "Computer Science Masters Program" 
  "A comprehensive 2-year masters program focusing on AI and machine learning"
  u1000)
```

### Vote on a Proposal
```clarity
;; Vote in favor of proposal ID 1
(contract-call? .ProgramVote vote u1 true)

;; Vote against proposal ID 1  
(contract-call? .ProgramVote vote u1 false)
```

### Check Proposal Status
```clarity
;; Get full proposal details
(contract-call? .ProgramVote get-proposal u1)

;; Get status as string
(contract-call? .ProgramVote get-proposal-status-string u1)
```

### Finalize Proposal
```clarity
;; Finalize proposal after voting period ends
(contract-call? .ProgramVote finalize-proposal u1)
```

## 📚 Contract Functions Documentation

### Public Functions

| Function | Parameters | Description | Access Control |
|----------|------------|-------------|----------------|
| `initialize` | None | Sets contract deployer as authorized voter | Anyone (one-time) |
| `add-authorized-voter` | `voter: principal` | Adds a new authorized voter | Contract Owner Only |
| `remove-authorized-voter` | `voter: principal` | Removes an authorized voter | Contract Owner Only |
| `create-proposal` | `title: string-ascii 100`<br>`description: string-ascii 500`<br>`voting-duration: uint` | Creates a new proposal | Authorized Voters Only |
| `vote` | `proposal-id: uint`<br>`vote-for: bool` | Casts vote on a proposal | Authorized Voters Only |
| `finalize-proposal` | `proposal-id: uint` | Finalizes proposal after voting ends | Anyone |

### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `is-authorized-voter` | `voter: principal` | `bool` | Checks if principal is authorized to vote |
| `get-proposal` | `proposal-id: uint` | `(optional proposal-data)` | Returns proposal details |
| `get-total-proposals` | None | `uint` | Returns total number of proposals created |
| `has-voted` | `proposal-id: uint`<br>`voter: principal` | `bool` | Checks if voter has voted on proposal |
| `get-proposal-status-string` | `proposal-id: uint` | `string-ascii` | Returns human-readable status |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `ERR_UNAUTHORIZED` | Caller not authorized for this action |
| u101 | `ERR_PROPOSAL_NOT_FOUND` | Proposal with given ID doesn't exist |
| u102 | `ERR_ALREADY_VOTED` | Voter has already voted on this proposal |
| u103 | `ERR_VOTING_CLOSED` | Voting period has ended or proposal finalized |
| u104 | `ERR_INVALID_PROPOSAL` | Proposal data is invalid |
| u105 | `ERR_ALREADY_AUTHORIZED` | Voter is already authorized |

## 🧪 Testing

### Run Tests
```bash
# Run all tests
npm run test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure
```
tests/
└── ProgramVote.test.ts    # Comprehensive test suite
```

## 🚀 Deployment Guide

### Local Development (Devnet)

1. **Start Clarinet console**
   ```bash
   clarinet console
   ```

2. **Deploy and interact with contract**
   ```clarity
   ;; Deploy contract
   ::deploy_contracts
   
   ;; Initialize contract
   (contract-call? .ProgramVote initialize)
   ```

### Testnet Deployment

1. **Configure testnet settings**
   ```bash
   # Edit settings/Testnet.toml with your testnet configuration
   ```

2. **Deploy to testnet**
   ```bash
   clarinet deployments generate --testnet
   clarinet deployments apply --testnet
   ```

### Mainnet Deployment

1. **Configure mainnet settings**
   ```bash
   # Edit settings/Mainnet.toml with your mainnet configuration
   ```

2. **Deploy to mainnet**
   ```bash
   clarinet deployments generate --mainnet
   clarinet deployments apply --mainnet
   ```

## 🔒 Security Considerations

### Access Control
- **Contract Owner Privileges**: Only the contract deployer can manage authorized voters
- **Voter Authorization**: Only authorized voters can create proposals and vote
- **One Vote Per Proposal**: Each voter can only vote once per proposal

### Voting Integrity
- **Time-Bound Voting**: Proposals have configurable voting deadlines
- **Immutable Votes**: Votes cannot be changed once cast
- **Transparent Results**: All voting data is publicly verifiable on-chain

### Proposal Validation
- **Input Validation**: Title and description cannot be empty
- **Duration Validation**: Voting duration must be greater than zero
- **Status Checks**: Proposals can only be voted on while active

### Best Practices
- Always initialize the contract after deployment
- Carefully manage authorized voter list
- Set appropriate voting durations for proposals
- Regularly monitor proposal status and finalize completed votes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Make your changes
4. Add tests for new functionality
5. Run the test suite (`npm run test`)
6. Commit your changes (`git commit -am 'Add new feature'`)
7. Push to the branch (`git push origin feature/new-feature`)
8. Create a Pull Request

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions, issues, or contributions:

- Create an issue in the GitHub repository
- Review the test files for usage examples
- Check the Clarity documentation for language-specific questions

---

**Built with ❤️ for decentralized education governance**