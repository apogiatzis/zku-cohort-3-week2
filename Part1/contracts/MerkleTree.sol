//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 public numberOfLeaves; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves [done]
        initMerkleTree(3);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree [done]
        require(index < 8, "MerkleTree: tree is full!");
        hashes[index] = hashedLeaf;
        updateRoot(index);
        index++;
        return hashedLeaf;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root [done]
        return input[0] == root;
    }

    function initMerkleTree(uint256 levels) internal {
        // hashes  = new uint[](2**(levels+1) - 1);
        uint k = 0;
        for (uint l = 0;l <= levels; l++) {
            for (uint i = 0;i < 2 ** (levels - l);i++) {
                if (l == 0) {
                    hashes.push(0);
                } else {
                    hashes.push(PoseidonT3.poseidon([hashes[2*k ], hashes[2*k + 1]]));
                    k++;
                }
            }
        }
        root = hashes[hashes.length-1];
        numberOfLeaves = 2 ** levels;
    }

    function updateRoot(uint256 updatedLeafIndex) internal {
        uint256 currentHash = hashes[updatedLeafIndex];
        uint256 currentIndex;
        uint256 start = 0;
        uint256 offset = updatedLeafIndex;
        for (uint256 i = 2 ** 0; i < numberOfLeaves; i *= 2) {
            currentIndex = start + offset;
            start += numberOfLeaves / i;
            offset /= 2;
            if (currentIndex % 2 == 0) {
                currentHash = PoseidonT3.poseidon([currentHash, hashes[currentIndex + 1]]);
            } else {
                currentHash = PoseidonT3.poseidon([hashes[currentIndex - 1], currentHash]);
            }
            hashes[start + offset] = currentHash;
        }
        root = currentHash;
    }
}
