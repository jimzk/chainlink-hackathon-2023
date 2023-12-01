# chainlink-hackathon-2023
This project is an entry for [Chainlink hackthon 2023 | Nov 8 - Dec 10](https://chain.link/hackathon)

## Introduction

## How to use

Suppose we want to aggregate 2 price signatures.

#1 Compile circuit

1. `cd circom && npm install`
2. Download Powers of Tau file with `2^22` constraints from [here](https://github.com/iden3/snarkjs#7-prepare-phase-2) and put it to `./circuits` with new name `pot22_final.ptau`.
3. Run `yarn build:wasm 2` to compile.
4. You will find the compiled artifacts in `./build`

#2 Pull prices and generate circuit witness and input.

1. `cd data-stream-parser`
2. Set environment variables for chainlink data stream API call.
    1. `export CLIENT_ID=f84c864e-xxxx-xxxx-xxxx-xxxxxxxxxxx`
    2. `export CLIENT_SECRET=TGA6dGpi...`
    3. `export BASE_URL=...` (Optional. The default value is `api.testnet-dataengine.chain.link`)
3. Run `cargo run 2`. It pulls price infos with signatures from chainlink data stream API and generates circuit witness and proof in `../circom/build/verify_2`.

#3 Verify in solidity smart contract

1. There is a solidity verifier demo in `./sol_verifier`.
2. Solidity verifier is a bit different for circuit on different number of price infos. Run `npx snarkjs zkey export solidityverifier [circuit_final.zkey] [verifier.sol]` under circuit artifacts directory to get solidity verifier code.
3. `npx snarkjs generatecall` to get call data `(pA, pB, pC, pubSignals)`.

Note: if you want to verify more price infos, you need to

- Download tau file with bigger power.
- Change the number in command, e.g. `yarn build:wasm 4` and `cargo run 4`.

## Future Work

- Check public key validity with registered signers from official chainlink datastream smart contract.
- Use aggregation or recursion technology to reduce the circuit constraints.
