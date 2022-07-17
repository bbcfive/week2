//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[15] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint16 i = 0; i < 15; i++) {
            hashes[i] = 0;
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[0] = hashedLeaf;

        uint256[8] memory results;
        for (uint8 i = 0; i < 4; i ++){
            results[i] = PoseidonT3.poseidon([hashes[i * 2], hashes[i * 2 + 1]]);
        }

        uint8 j = 0;
        for (uint8 i = 4; i < 7; i ++) {
            results[i] = PoseidonT3.poseidon([results[j * 2], results[j * 2 + 1]]);
            j ++;
        }
       
        return results[6];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
