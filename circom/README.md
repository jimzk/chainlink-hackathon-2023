The project is an circuit implementation for batch verification of chainlink prices signatures.

**Warning**: this code is highly experimental and unaudited. Please use at your own risk.

## Project overview

- `circuits` contains the circuits
- `scripts` contains scripts for compiling circuits and generating proofs

## Dependencies

- Run `yarn` at the top level to install npm dependencies (`snarkjs` and `circomlib`).
- You'll also need `circom` version `>= 2.0.2` on your system. Installation instructions [here](https://docs.circom.io/getting-started/installation/).

## Building

- `yarn build:wasm 2`: Build the circuit in wasm in batch of number 2.

## Acknowledgments

Thanks to

- [circom-ecdsa](https://github.com/0xparc/circom-ecdsa)
- [batch-ecdsa](https://github.com/puma314/batch-ecdsa)
