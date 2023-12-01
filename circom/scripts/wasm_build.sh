#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

if [ "$1" == "" ]; then
	echo -e "${RED}No batch number provided. Exiting...${RESET}"
	exit 1
fi
NUM="$1"

declare -A myMap
myMap["2"]="22"
myMap["4"]="22"
myMap["8"]="23"
myMap["16"]="24"

POT_NUM=${myMap[$NUM]}
if [ -z "$POT_NUM" ]; then
	echo -e "${RED}Do not support to aggretaion $NUM prices. Available value: 2, 4, 8, 16${RESET}"
	echo -e "${RED}Exiting...${RESET}"
	exit 1
fi

PHASE1=../circuits/pot${POT_NUM}_final.ptau
BUILD_DIR=../build/verify_"${1}"
CIRCUIT_NAME=verify_"${1}"
CIRCUIT_DIR="../circuits"
INPUT=../test/input_"${1}".json

if [ -f "$PHASE1" ]; then
	echo -e "${GREEN}Phase 1 ptau file pot${POT_NUM}_final.ptau FOUND!${RESET}"
else
	echo -e "${RED}Phase 1 ptau file pot${POT_NUM}_final.ptau NOT FOUND!${RESET}"
	echo "${RED}Compiling circuits of $NUM prices aggregation needs ptau with power of at leat ${POT_NUM}${RESET}"
	echo -e "${RED}Download it from https://github.com/iden3/snarkjs#7-prepare-phase-2 to ./circuits/pot${POT_NUM}_final.ptau${RESET}"
	echo -e "${RED}Exiting...${RESET}"
	exit 1
fi

if [ ! -d "$BUILD_DIR" ]; then
	echo -e "${RED}No build directory found. Creating build directory...${RESET}"
	mkdir -p "$BUILD_DIR"
fi

echo "****COMPILING CIRCUIT****"
start=$(date +%s)
set -x
circom "$CIRCUIT_DIR"/"$CIRCUIT_NAME".circom --r1cs --wasm --sym --wat --output "$BUILD_DIR"
if [ $? -ne 0 ]; then
	echo -e "${RED}Circuit compilation failed. Exiting...${RESET}"
	exit 1
fi

{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "****GENERATING ZKEY 0****"
start=$(date +%s)
npx snarkjs groth16 setup "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$PHASE1" "$BUILD_DIR"/0.zkey
if [ $? -ne 0 ]; then
	echo -e "${RED}Fail to generating ZKEY 0. Exiting...${RESET}"
	exit 1
fi
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "****GENERATING FINAL ZKEY****"
start=$(date +%s)
npx snarkjs zkey beacon "$BUILD_DIR"/0.zkey "$BUILD_DIR"/final.zkey 0102030405060708090a0b0c0d0e0f101112231415161718221a1b1c1d1e1f 10 -n="Final Beacon phase2"
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "** Exporting vkey"
start=$(date +%s)
npx snarkjs zkey export verificationkey "$BUILD_DIR"/final.zkey "$BUILD_DIR"/vkey.json
end=$(date +%s)
echo "DONE ($((end - start))s)"

if [ "$2" == "--only-build" ]; then
	echo -e "${GREEN}Only build.${RESET}"
	exit 0
fi

echo "****GENERATING WITNESS****"
start=$(date +%s)
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm "$INPUT" "$BUILD_DIR"/witness.wtns
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "****GENERATING PROOF****"
start=$(date +%s)
npx snarkjs groth16 prove "$BUILD_DIR"/final.zkey "$BUILD_DIR"/witness.wtns "$BUILD_DIR"/proof.json "$BUILD_DIR"/public.json
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "****VERIFYING PROOF****"
start=$(date +%s)
npx snarkjs groth16 verify "$BUILD_DIR"/vkey.json "$BUILD_DIR"/public.json "$BUILD_DIR"/proof.json
end=$(date +%s)
echo "DONE ($((end - start))s)"

echo "DONE"
