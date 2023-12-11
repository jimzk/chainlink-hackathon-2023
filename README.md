# chainlink-hackathon-2023
This project is an entry for [Chainlink hackthon 2023 | Nov 8 - Dec 10](https://chain.link/hackathon).

## Introduction
This repo contains demo UI, Chainlink data streams parser, circom script and smart contract. It is a poc of minimal components that can form our zk-Oracle prototype in the future.

### UI
Based on react and part of the UI calls are mocked for now (due to the long compilation waiting time)

### Data streams parser
A component that fetches and parses chainlin data streams data.

### Circom
A component that verifies signatures and generates zk-proof as well as witness for onchain verification

### Sol verifier
Smart contract that we deploy on chain to do verification

## Quick Start

1. Download Tau file with power `22` from [here](https://github.com/iden3/snarkjs#7-prepare-phase-2) to `./circom/circuits/pot22_final.ptau`
2. Set environment variables for chainlink data stream API credentials.
    - `export CLIENT_ID=f84c864e-xxxx-xxxx-xxxx-xxxxxxxxxxx`
    - `export CLIENT_SECRET=TGA6dGpi...`
    - `export BASE_URL=...` (Optional, the default is `api.testnet-dataengine.chain.link`)
3. Run `./all-in-one.sh 2`. This script compiles circuit, parses price infos from chainlink datastream API and runs solidity verifier locally.

NOTE: if you want to verify more price infos, you should:

- Download tau file with bigger power.
- Change the number in command, e.g. `./all-in-one.sh 4`.

## Gas Cost

| The number of prices | Constraints | Gas cost of our verification on EVM | Gas cost of current verification on EVM [1] |
| -------------------- | ----------- | ----------------------------------- | ------------------------------------------- |
| 2                    | 2,296,105   | 345,731                             | ~240,000                                    |
| 4                    | 3,522,039   | 373,257                             | ~480,000                                    |
| 8                    | 5,973,907   | 431,465                             | ~960,000                                    |
| 16                   | 10,877,643  | 554,193                             | ~1,920,000                                  |

[1] Gas cost of pure single price verification is roughly 120,000, which is estimated based on [the real gas cost](https://sepolia.arbiscan.io/tx/0x5c0954edaa09915af7f3e033424354e1711d155189592825d406f0ac6daf7c9f) onchain.


## Future Work

- Check public key validity with registered signers from official chainlink datastream smart contract.
- Use aggregation or recursion technology to reduce the circuit constraints.
