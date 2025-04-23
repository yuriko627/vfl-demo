#!/usr/bin/env bash

# Check if client ID was provided
if [ -z "$1" ]; then
    echo "Usage: ./train.sh <client_id>"
    exit 1
fi

client_id=$1

echo "🧑‍🏫 Start training a model on Client${client_id}..."

echo "💻 Running logistic regression ZK circuit..."

# Train a model and capture the output
cd ./training
training_output=$(nargo execute 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ nargo execute failed:"
    echo "$training_output"
    exit 1
fi

# Save pk_x and pk_y to /tmp for masking use
echo "✅ Training ZK circuit executed: Training done!"
echo $training_output | grep -oE 'pk_x: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > "/tmp/pk${client_id}_x"
echo $training_output | grep -oE 'pk_y: 0x[0-9a-fA-F]+' | grep -oE '0x[0-9a-fA-F]+' > "/tmp/pk${client_id}_y"

priv_key=$client_id

# Generate proof
echo "👾 Generate a proof for correct training..."
bb prove -b "./target/client${client_id}_training.json" -w "./target/client${client_id}_training.gz" -o ./target/proof

# Parse the output model and write to Prover.toml in ./masking directory
bash ../../../scripts/parse_trained_model.sh \
  "$training_output" \
  ../masking/Prover.toml \
  "$priv_key"

PKREGISTRY_ADDRESS=$(cat /tmp/pkregistry_address)
TRAIN_VERIFIER_ADDRESS=$(cat /tmp/client${client_id}trainverifier_address)
PROOF=$(od -An -v -t x1 ./target/proof | tr -d ' \n')
PK_X=$(cat /tmp/pk${client_id}_x)
PK_Y=$(cat /tmp/pk${client_id}_y)
PRIVATE_KEY=$(bash ../../../scripts/extract_eth_accounts.sh privatekey ${client_id})

echo "📝 Send transaction to verify training proof and register ECDH public key on chain"
echo "🧾 Transaction Receipt:"
cast send "$PKREGISTRY_ADDRESS" \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x"$PROOF" \
  "$TRAIN_VERIFIER_ADDRESS" \
  "$PK_X" \
  "$PK_Y" \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key "$PRIVATE_KEY"




