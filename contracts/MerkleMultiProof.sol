//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MerkleMultiProof {

   /**
     * @notice Calculates a merkle root using multiple leafs at same time
     * @param leafs out of order sequence of leafs and it's siblings
     * @param proofs out of order sequence of parent proofs
     * @param proofFlag flags for using or not proofs while hashing against hashes.
     * @return merkleRoot of tree
     */
    function processMultiMerkleRoot(
        bytes32[] memory leafs,
        bytes32[] memory proofs,
        bool[] memory proofFlag //returns if the value is generated from leaves with help of proof 
    )
        internal
        pure
        returns (bytes32 merkleRoot)
    {
        uint256 leafsLen = leafs.length;
        uint256 totalHashes = proofFlag.length;
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint leafPos = 0;
        uint hashPos = 0;
        uint proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for(uint256 i = 0; i < totalHashes; i++){
            hashes[i] = hashPair(
                proofFlag[i] ? (leafPos < leafsLen ? leafs[leafPos++] : hashes[hashPos++]) : proofs[proofPos++],
                leafPos < leafsLen ? leafs[leafPos++] : hashes[hashPos++]
                
            );
        }

        return hashes[totalHashes-1];
    }

    function hashPair(bytes32 a, bytes32 b) private pure returns(bytes32){
        return a < b ? hash_node(a, b) : hash_node(b, a);
    }

    function hash_node(bytes32 left, bytes32 right)
        private pure
        returns (bytes32 hash)
    {
        assembly {
            mstore(0x00, left)
            mstore(0x20, right)
            hash := keccak256(0x00, 0x40)
        }
        return hash;
    }


    /**
     * @notice Check validity of multimerkle proof
     * @param root merkle root
     * @param leafs out of order sequence of leafs and it's siblings
     * @param proofs out of order sequence of parent proofs
     * @param proofFlag flags for using or not proofs while hashing against hashes.
     */

    function verifyMultiProof(
        bytes32 root,
        bytes32[] memory leafs,
        bytes32[] memory proofs,
        bool[] memory proofFlag
    )
        public
        pure
        returns (bool)
    {
        return processMultiMerkleRoot(leafs, proofs, proofFlag) == root;
    }

}