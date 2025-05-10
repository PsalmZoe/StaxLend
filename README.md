# DeFi-StaxLend

A decentralized lending protocol built on the Stacks blockchain using Clarity smart contracts.

## Overview

DeFi-StaxLend enables users to deposit STX as collateral and borrow against it. The protocol maintains a minimum collateral ratio to ensure system solvency and implements basic lending functionality.

## Features

- Deposit STX tokens
- Withdraw deposited tokens
- Borrow STX against collateral
- Repay loans
- Claim collateral after loan repayment

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks Wallet](https://www.hiro.so/wallet)

### Installation

1. Clone the repository
## Usage

The contract provides the following functions:

- `deposit`: Deposit STX tokens into the protocol
- `withdraw`: Withdraw previously deposited STX
- `borrow`: Borrow STX by providing collateral
- `repay`: Repay an existing loan
- `claim-collateral`: Claim back collateral after loan repayment
