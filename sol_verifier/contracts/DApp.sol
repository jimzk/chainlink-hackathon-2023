pragma solidity >=0.7.0 <0.9.0;

import "./Verifier.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

uint256 constant NUM_PRICES = 2;
uint256 constant PUB_SIGNALS_LEN = 1 + (4 + 8) * NUM_PRICES;

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

    function verifyAndParsePrice(
        bytes32[3][NUM_PRICES] memory reportContexts,
        bytes[NUM_PRICES] memory reportDatum,
        uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[PUB_SIGNALS_LEN] calldata pubSignals)
    public view returns (PriceReport[NUM_PRICES] memory) {
        PriceReport[NUM_PRICES] memory priceReports;

        for (uint i = 0; i < NUM_PRICES; i++) {
            // Check publicKey
            uint[4] memory x;
            x[0] = pubSignals[NUM_PRICES * 4 + 8 * i + 1];
            x[1] = pubSignals[NUM_PRICES * 4 + 8 * i + 2];
            x[2] = pubSignals[NUM_PRICES * 4 + 8 * i + 3];
            x[3] = pubSignals[NUM_PRICES * 4 + 8 * i + 4];
            uint[4] memory y;
            y[0] = pubSignals[NUM_PRICES * 4 + 8 * i + 5];
            y[1] = pubSignals[NUM_PRICES * 4 + 8 * i + 6];
            y[2] = pubSignals[NUM_PRICES * 4 + 8 * i + 7];
            y[3] = pubSignals[NUM_PRICES * 4 + 8 * i + 8];
            if (!verifyPublicKey(x, y)) {
                revert (string(abi.encodePacked("publicKey ", Strings.toString(i), " not match")));
            }
            // Check msgHash
            bytes32[3] memory reportContext = reportContexts[i];
            bytes memory reportData = reportDatum[i];
            bytes32 hasedReport = keccak256(reportData);
            bytes32 msgHash = keccak256(abi.encodePacked(hasedReport, reportContext));
            bytes32 givenMsgHash = 0;
            givenMsgHash |= bytes32(uint256(pubSignals[4 * i + 1])) << 0;
            givenMsgHash |= bytes32(uint256(pubSignals[4 * i + 2])) << 64;
            givenMsgHash |= bytes32(uint256(pubSignals[4 * i + 3])) << 128;
            givenMsgHash |= bytes32(uint256(pubSignals[4 * i + 4])) << 192;
            if (givenMsgHash != msgHash) {
                revert (string(abi.encodePacked("msgHash ", Strings.toString(i), " not match")));
            }
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
