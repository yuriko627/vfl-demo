#!/usr/bin/env fish

echo "Start training a model on client1"

# Train a model and generate a proof
nargo execute
bb prove -b ./target/client1_training.json -w ./target/client1_training.gz -o ./target/proof
bb write_vk -b ./target/client1_training.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/pkregistry/src/Client1Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client1Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client1BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client1VerificationKey' \
    > $dest_path

echo "Client 1: training done, verifier contract is ready to deploy"