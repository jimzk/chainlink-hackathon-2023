const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Dapp", function () {
  async function deployDApp() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const DApp = await ethers.getContractFactory("DApp");
    const dapp = await DApp.deploy();

    return { dapp, owner, otherAccount };
  }

  function readProofInput() {
    const json = require("./proof_input.json");
    pA = json[0];
    pB = json[1];
    pC = json[2];
    publicSigns = json[3];
    return { pA, pB, pC, publicSigns };
  }

  function readReports() {
    const json = require("./reports.json");
    reportContexts = json[0];
    reportBlobs = json[1];
    return { reportContexts, reportBlobs };
  }

  describe("verifyProof", function () {
    it("Call verifyProof", async function () {
      const { dapp } = await loadFixture(deployDApp);

      const { pA, pB, pC, publicSigns } = readProofInput();
      const result = await dapp.verifyProof(pA, pB, pC, publicSigns);
      expect(result).to.equal(true);
    });
  });

  describe("verifyAndParsePrice", function () {
    it("Call verifyAndParsePrice", async function () {
      const { dapp, owner } = await loadFixture(deployDApp);
      const { pA, pB, pC, publicSigns } = readProofInput();
      const { reportContexts, reportBlobs } = readReports();
      const result = await dapp.verifyAndParsePrice(
        reportContexts,
        reportBlobs,
        pA,
        pB,
        pC,
        publicSigns
      );
      const expected = [
        [
          "0x0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e683",
          "1700448180",
          "1700448180",
          "5000",
          "663200",
          "1700534580",
          "15077819460140741500",
        ],
        [
          "0x0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e683",
          "1700448190",
          "1700448190",
          "5000",
          "663800",
          "1700534590",
          "15065681500000000000",
        ],
      ];
      for (let i = 0; i < expected.length; i++) {
        for (let j = 0; j < expected[i].length; j++) {
          expect(result[i][j]).to.equal(expected[i][j]);
        }
      }

      // Estimate gas cost
      await dapp
        .connect(owner)
        .updatePriceMA(reportContexts, reportBlobs, pA, pB, pC, publicSigns);
    });
  });
});
