#!/bin/bash

cd circuits

if [ -f ./powersOfTau28_hez_final_12.ptau ]; then
    echo "powersOfTau28_hez_final_12.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_12.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau
fi

echo "Compiling merkletree.circom..."

# compile merkletree circuit

circom merkletree.circom --r1cs --wasm --sym -o .
snarkjs r1cs info merkletree.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup merkletree.r1cs powersOfTau28_hez_final_12.ptau merkletree_0000.zkey
snarkjs zkey contribute merkletree_0000.zkey merkletree_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey merkletree_final.zkey verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier merkletree_final.zkey ../contracts/verifier.sol

cd ..