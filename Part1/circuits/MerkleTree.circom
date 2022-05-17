pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves [done]
    component hashers[(2**n)-1];

    var k = 0;
    for(var level = 0; level < n; level++) {
        for(var i = 0; i < 2**(n - 1 -level); i++) {
            hashers[k] = Poseidon(2);
            if (level == 0) {
                hashers[k].inputs[0] <-- leaves[i * 2];
                hashers[k].inputs[1] <-- leaves[i * 2 + 1];
            } else {
                hashers[k].inputs[0] <-- hashers[(k-2**(n-1)) * 2].out;
                hashers[k].inputs[1] <-- hashers[(k-2**(n-1)) * 2 + 1].out;
            }
            k++;
        }
    }

    if (n > 0){
        root <== hashers[(2**n)-2].out;
    }

}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path [done]
    component hashers[n];

    var hash = leaf;

    var left_hash, right_hash;
    for (var i = 0; i < n; i++) {
        hashers[i] = Poseidon(2);
        if (path_index[i] == 0) {
            left_hash = hash;
            right_hash = path_elements[i];
        } else {
            left_hash = path_elements[i];
            right_hash = hash;
        }
        
        hashers[i].inputs[0] <-- left_hash;
        hashers[i].inputs[1] <-- right_hash;

        hash = hashers[i].out;
    }

    root <== hash;
}