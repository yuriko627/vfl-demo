#!/usr/bin/env fish

# Check if client ID was provided
if not set -q argv[1]
    echo "Usage: ./train_client.fish <client_id>"
    exit 1
end

set client_id $argv[1]

echo "Start training a model on Client$client_id"

# Train a model and capture the output
set training_output (nargo execute 2>&1)

# Save pk_x and pk_y to /tmp for masking use
echo "Training ZKcircuit executed: Training done"
echo $training_output | grep -oE 'pk_x: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > /tmp/pk{$client_id}_x
echo $training_output | grep -oE 'pk_y: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > /tmp/pk{$client_id}_y

set priv_key $client_id

# Parse the output model and write to Prover.toml in ./masking directory
bash ../../../scripts/parse_trained_model.sh \
  "$training_output" \
  ../masking/Prover.toml \
  "$priv_key"

# Generate proof and verifier contract
bb prove -b ./target/client{$client_id}_training.json -w ./target/client{$client_id}_training.gz -o ./target/proof
bb write_vk -b ./target/client{$client_id}_training.json -o ./target/vk
bb contract

# Rename and customize verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/pk_registry/src/Client{$client_id}Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' "Client"$client_id"Verifier" | \
    string replace -a --regex 'BaseUltraVerifier\b' "Client"$client_id"BaseVerifier" | \
    string replace -a --regex 'UltraVerificationKey\b' "Client"$client_id"VerificationKey" \
    > $dest_path

echo "Client $client_id: training done, verifier contract is ready to deploy"
