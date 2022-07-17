pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var i;
    var j;

    var nodes = 0;
    for (i = 0; i < n; i ++) {
        nodes += 2 ** i;
    }

    component poseidon[nodes];

    for (i = 0; i < nodes; i ++) {
        poseidon[i] = Poseidon(2);
    }

    for (i = 0; i < 2 ** (n - 1); i ++){
        poseidon[i].inputs[0] <== leaves[i * 2];
        poseidon[i].inputs[1] <== leaves[i * 2 + 1];
    }

    j = 0;
    for (i = 2 ** (n - 1); i < nodes; i ++) {
        poseidon[i].inputs[0] <== poseidon[j * 2].out;
        poseidon[i].inputs[1] <== poseidon[j * 2 + 1].out;
        j ++;
    }

    root <== poseidon[nodes-1].out;
}

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;
    hash <== hasher.out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component nodes[n];
    component switch[n];

    for (var i = 0; i < n; i++) {
        nodes[i] = HashLeftRight();
        switch[i] = MultiMux1(2);

        switch[i].c[0][0] <== i == 0 ? leaf : nodes[i - 1].hash;
        switch[i].c[0][1] <== path_elements[i];
        switch[i].c[1][0] <== path_elements[i];
        switch[i].c[1][1] <== i == 0 ? leaf : nodes[i - 1].hash;
        switch[i].s <== path_index[i];
        nodes[i].left <== switch[i].out[0];
        nodes[i].right <== switch[i].out[1];
    }

    root <== nodes[n - 1].hash;
}