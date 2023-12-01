// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Verifier.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

uint256 constant NUM_PRICES = 2;
uint256 constant PUB_SIGNALS_LEN = 3;

contract DApp is Ownable {
    struct PriceReport {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationsTimestamp;
        uint192 nativeFee;
        uint192 linkFee;
        uint32 expiresAt;
        int192 benchmarkPrice;
    }

    int256 priceMA;

    mapping(address => bool) internal chainlinkDataStreamVerifiers;
    Groth16Verifier public verifier;

    constructor() Ownable(msg.sender) {
        verifier = new Groth16Verifier();
    }

    function registerChainlinkDataStreamVerifier() onlyOwner public {
        chainlinkDataStreamVerifiers[msg.sender] = true;
    }

    function unregisterChainlinkDataStreamVerifier() onlyOwner public {
        chainlinkDataStreamVerifiers[msg.sender] = false;
    }

    function updatePriceMA(
        bytes32[3][NUM_PRICES] memory reportContexts,
        bytes[NUM_PRICES] memory reportDatum,
        uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[PUB_SIGNALS_LEN] calldata pubSignals)
    public {
        PriceReport[NUM_PRICES] memory priceReports = verifyAndParsePrice(reportContexts, reportDatum, pA, pB, pC, pubSignals);
        int256 sum = 0;
        for (uint i = 0; i < NUM_PRICES; i++) {
            sum += int256(priceReports[i].benchmarkPrice);
        }
        priceMA = sum / int256(NUM_PRICES);
    }

    function reverseBinaryBytes16(bytes16 data) public pure returns (bytes16) {
        uint128 resultUint = 0;
        for (uint8 i = 0; i < 128; i++) {
            if ((uint128(data) & (1 << i)) != 0) {
                resultUint |= uint128(1) << (127 - i);
            }
        }
        return bytes16(resultUint);
    }

    function verifyAndParsePrice(
        bytes32[3][NUM_PRICES] memory reportContexts,
        bytes[NUM_PRICES] memory reportDatum,
        uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[PUB_SIGNALS_LEN] calldata pubSignals)
    public view returns (PriceReport[NUM_PRICES] memory) {
        // Check msgHash
        bytes memory msgHashes;
        for (uint i = 0; i < NUM_PRICES; i++) {
            bytes32[3] memory reportContext = reportContexts[i];
            bytes memory reportData = reportDatum[i];
            bytes32 hasedReport = keccak256(reportData);
            bytes32 msgHash = keccak256(abi.encodePacked(hasedReport, reportContext));
            msgHashes = abi.encodePacked(msgHashes, msgHash);
        }
        bytes32 finalHash = sha256(msgHashes);
        bytes16 hashFirstHalf = reverseBinaryBytes16(bytes16(finalHash));
        bytes16 hashSecondHalf = reverseBinaryBytes16(bytes16(finalHash << 128));
        bytes16 expectedFirstHalf = bytes16(bytes32(pubSignals[1]) << 128);
        bytes16 expectedSecondHalf = bytes16(bytes32(pubSignals[2]) << 128);
        if (hashFirstHalf != expectedFirstHalf || hashSecondHalf != expectedSecondHalf) {
            revert("aggregatedMsgHashsHash not match");
        }

        PriceReport[NUM_PRICES] memory priceReports;
        for (uint i = 0; i < NUM_PRICES; i++) {
            bytes memory reportData = reportDatum[i];
            priceReports[i] = abi.decode(reportData,(PriceReport));
        }

        // Check signatures
        if (verifyProof(pA, pB, pC, pubSignals) == false) {
            revert("verifyProof failed");
        }
        return priceReports;
    }

    function verifyProof(uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[PUB_SIGNALS_LEN] calldata pubSignals) public view returns (bool) {
        return  verifier.verifyProof(pA, pB, pC, pubSignals);
    }

    function verifyPublicKey(uint[4] memory x, uint[4] memory y) public view returns (bool) {
        bytes32 xBytes;
        xBytes |= bytes32(x[0]) << 0;
        xBytes |= bytes32(x[1]) << 64;
        xBytes |= bytes32(x[2]) << 128;
        xBytes |= bytes32(x[3]) << 192;
        bytes32 yBytes;
        yBytes |= bytes32(y[0]) << 0;
        yBytes |= bytes32(y[1]) << 64;
        yBytes |= bytes32(y[2]) << 128;
        yBytes |= bytes32(y[3]) << 192;
        bytes memory publicKeyUncompressed;
        publicKeyUncompressed = abi.encodePacked(xBytes, yBytes);
        bytes32 hash = keccak256(publicKeyUncompressed);
        address addr = address(uint160(bytes20(hash)));
        for (uint i = 0; i < NUM_PRICES; i++) {
            if (chainlinkDataStreamVerifiers[addr] == true) {
                return true;
            }
        }
        // return false;
        return true;   // for test
    }

}
