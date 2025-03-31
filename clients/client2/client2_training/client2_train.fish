#!/usr/bin/env fish

echo "Start training a model on client2"

# Train a model and generate a proof
nargo execute
bb prove -b ./target/client2_training.json -w ./target/client2_training.gz -o ./target/proof
bb write_vk -b ./target/client2_training.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/pkregistry/src/Client2Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client2Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client2BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client2VerificationKey' \
    > $dest_path

echo "Client 2: training done, verifier contract is ready to deploy"