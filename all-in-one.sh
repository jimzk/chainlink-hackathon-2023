#!/usr/bin/env bash

set -e

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${BLUE}Start to build circuit, pull price infos from chainlink datastream API and verify zk proof.${RESET}"

# check $1 is a number
if ! [[ $1 =~ ^[0-9]+$ ]]; then
	echo -e "${RED}Error: $1 is not a number. Exist.${RESET}"
	exit 1
fi
NUM=$1

# 0. Prepare
echo -e "${BLUE}#0 Install dependencies ...${RESET}"
(cd circom && npm i)
(cd sol_verifier && npm i)

# 1. Build circuits
cd circom
echo -e "${BLUE}#1 Start building circuits ...${RESET}"
start=$(date +%s)
yarn build:wasm "$NUM" --only-build 2>err"${NUM}".log
end=$(date +%s)
echo -e "${BLUE}#1 Done building circuits ($((end - start))s).${RESET}"

# 2. Pull price infos from chainlink data-stream API
cd ../data-stream-parser/ || exit
echo -e "${BLUE}#2 Start pulling price infos from chainlink data-stream API ...${RESET}"
start=$(date +%s)
cargo run "$NUM"
cp reports.json ../sol_verifier/test/reports.json
end=$(date +%s)
echo -e "${BLUE}#2 Done pulling price infos from chainlink data-stream API ($((end - start))s).${RESET}"

# 3. Verified by solidity
cd ../circom/build/verify_"${NUM}"/ || exit
echo -e "${BLUE}#3 Start verifying ...${RESET}"
start=$(date +%s)
npx snarkjs zkey export solidityverifier final.zkey ../../../sol_verifier/contracts/Verifier.sol
echo "[$(npx snarkjs generatecall)]" >../../../sol_verifier/test/proof_input.json

cd ../../../sol_verifier
sed -Ei "s/NUM_PRICES = [0-9]+;/NUM_PRICES = ${NUM};/g" ./contracts/DApp.sol
npx hardhat test
end=$(date +%s)
echo -e "${BLUE}#3 Done verifying ($((end - start))s).${RESET}"

echo -e "${BLUE}Done${RESET}"
# sed -e "s/\x1B[^m]*m//g" log
