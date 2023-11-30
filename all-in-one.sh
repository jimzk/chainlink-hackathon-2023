#!/bin/bash

# This script do 3 things
# 1. Build circom circuits
# 2. Pull price info from chainlink data-stream
# 3. Run solidity test

# check $1 is a number
if ! [[ $1 =~ ^[0-9]+$ ]]; then
	echo "Error: $1 is not a number"
	exit 1
fi
num=$1

# Prepare
git submodule update --init --recursive
cd circom-ecdsa-batch || exit
(cd circuits/circom-ecdsa && npm i)
npm i

# Build circuits
yarn build:wasm "$num"
cd build/batch_ecdsa_verify_"${num}"/ || exit
npx snarkjs zkey export solidityverifier batch_ecdsa_verify_"${num}".zkey verifier.sol

# Pull price info
cd ../../../data-stream-parser/ || exit
cargo run "$num"
cp reports.json ../sol_verifier/test/reports.json

# Run solidity test
cd ../circom-ecdsa-batch/build/batch_ecdsa_verify_"${num}"/ || exit
cp verifier.sol ../../../sol_verifier/contracts/Verifier.sol
sol_calldata=$(npx snarkjs generatecall)
sol_calldata="[${sol_calldata}]"
echo "$sol_calldata" >../../../sol_verifier/test/proof_input.json

cd ../../../sol_verifier/ || exit
npx hardhat test

# sed -e "s/\x1B[^m]*m//g" log
