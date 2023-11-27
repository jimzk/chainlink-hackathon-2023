import "./Verifier.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

uint256 constant NUM_PRICES = 2;

contract DApp {
    struct PriceReport {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationsTimestamp;
        uint192 nativeFee;
        uint192 linkFee;
        uint32 expiresAt;
        int192 benchmarkPrice;
    }

    int256 PriceMA;

    Groth16Verifier public verifier;

    constructor() {
        verifier = new Groth16Verifier();
    }

    function updatePriceMA(
        bytes32[3][NUM_PRICES] memory reportContexts,
        bytes[NUM_PRICES] memory reportDatum,
        uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[25] calldata pubSignals)
    public {
        PriceReport[NUM_PRICES] memory priceReports = verifyAndParsePrice(reportContexts, reportDatum, pA, pB, pC, pubSignals);
        int256 sum = 0;
        for (uint i = 0; i < NUM_PRICES; i++) {
            sum += int256(priceReports[i].benchmarkPrice);
        }
        PriceMA = sum / int256(NUM_PRICES);
    }

    function verifyAndParsePrice(
        bytes32[3][NUM_PRICES] memory reportContexts,
        bytes[NUM_PRICES] memory reportDatum,
        uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[25] calldata pubSignals)
    public view returns (PriceReport[NUM_PRICES] memory) {
        PriceReport[NUM_PRICES] memory priceReports;
        for (uint i = 0; i < NUM_PRICES; i++) {
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
        if (verifyProof(pA, pB, pC, pubSignals) == false) {
            revert("verifyProof failed");
        }
        return priceReports;
    }

    function verifyProof(uint[2] calldata pA, uint[2][2] calldata pB, uint[2] calldata pC, uint[25] calldata pubSignals) public view returns (bool) {
        return  verifier.verifyProof(pA, pB, pC, pubSignals);
    }

}
