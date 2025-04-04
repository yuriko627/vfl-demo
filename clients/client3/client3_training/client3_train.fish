#!/usr/bin/env fish

echo "Start training a model on Client3"

# Train a model and generate a proof for it
set training_output (nargo execute 2>&1)

# We'll use this variable later for maksing (when executing client1_mask.fish)
echo "Training ZKcircuit executed: Training done"
echo $training_output | grep -oE 'pk_x: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > /tmp/pk3_x
echo $training_output | grep -oE 'pk_y: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > /tmp/pk3_y

set priv_key 3

# Parse the output model and write to Prover.toml in ./client1_masking directory
fish ../../../parse_trained_model.fish \
  "$training_output" \
  ../client3_masking/Prover.toml \
  "$priv_key"

bb prove -b ./target/client3_training.json -w ./target/client3_training.gz -o ./target/proof
bb write_vk -b ./target/client3_training.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/pkregistry/src/Client3Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client3Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client3BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client3VerificationKey' \
    > $dest_path

echo "Client 3: training done, verifier contract is ready to deploy"
