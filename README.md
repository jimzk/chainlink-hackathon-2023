# chainlink-hackathon-2023
This project is an entry for [Chainlink hackthon 2023 | Nov 8 - Dec 10](https://chain.link/hackathon).

## Introduction


## How to use

1. Download Tau file with power `22` from [here](https://github.com/iden3/snarkjs#7-prepare-phase-2) to `./circom/circuits/pot22_final.ptau`
2. Set environment variables for chainlink data stream API credentials.
    - `export CLIENT_ID=f84c864e-xxxx-xxxx-xxxx-xxxxxxxxxxx`
    - `export CLIENT_SECRET=TGA6dGpi...`
    - `export BASE_URL=...` (Optional, the default is `api.testnet-dataengine.chain.link`)
3. Run `./all-in-one.sh 2`. This script compiles circuit, parses price infos from chainlink datastream API and runs solidity verifier locally.

NOTE: if you want to verify more price infos, you should:

- Download tau file with bigger power.
- Change the number in command, e.g. `./all-in-one.sh 4`.

## Future Work

- Check public key validity with registered signers from official chainlink datastream smart contract.
- Use aggregation or recursion technology to reduce the circuit constraints.
