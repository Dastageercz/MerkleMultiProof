const MerkleMultiProof = artifacts.require("MerkleMultiProof");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

contract("MerkleMultiProof", (accounts) => {
  let contract;

  before("setup", async () => {
    contract = await MerkleMultiProof.new();
  });

  context("MerkleMultiProof", () => {
    describe("verifyMultiProof()", () => {
      it("should verify for valid merkle multiproof (example)", async () => {
        const leaves = ["a", "b", "c", "d", "e", "f" , "g", "h"]
          .map(keccak256)
          .sort(Buffer.compare);
        const tree = new MerkleTree(leaves, keccak256, { sort: true });
        console.log("tree", tree.toString());

        const root = tree.getRoot();
        console.log("Root:", root.toString("hex"));

        const proofLeaves = ["b", "f", "c", "h"].map(keccak256).sort(Buffer.compare);
        for (let i = 0; i < proofLeaves.length; i++) {
          console.log(`proofLeaves${i}`, proofLeaves[i].toString("hex"));
        }

        const proof = tree.getMultiProof(proofLeaves);
        for (let i = 0; i < proof.length; i++) {
          console.log(`proof${i}`, proof[i].toString("hex"));
        }

        const proofFlags = tree.getProofFlags(proofLeaves, proof);
        console.log("proofFlags", proofFlags);

        const verified = await contract.verifyMultiProof.call(
          root,
          proofLeaves,
          proof,
          proofFlags
        );
        assert.equal(verified, true);
      });
    });
  });
});
