#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: mask.sh <client_id>"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

client_id=$1

# Derive paths based on client ID
PKREGISTRY_ADDRESS=$(cat /tmp/pkregistry_address)
TRAIN_VERIFIER_ADDRESS=$(cat /tmp/client${client_id}trainverifier_address)
PROOF=$(od -An -v -t x1 ./training/target/proof | tr -d ' \n')
PK_X=$(cat /tmp/pk${client_id}_x)
PK_Y=$(cat /tmp/pk${client_id}_y)
PRIVATE_KEY=$(bash ../../scripts/extract_eth_accounts.sh privatekey ${client_id})
CALLER_ADDRESS=$(bash ../../scripts/extract_eth_accounts.sh address ${client_id})

echo "👻 Start masking a model on Client${client_id}"

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

# Fot the sake of this CLI demo, we just wait for a bit for all the clients to submit their public keys  — will need coordination solution in the future
if [ "$client_id" -eq 1 ]; then
  sleep 27
fi
if [ "$client_id" -eq 2 ] || [ "$client_id" -eq 3 ]; then
  sleep 2
fi

echo "🔑 Fetch 2 neighbor clients' public keys"

fetched_output=$(cast call "$PKREGISTRY_ADDRESS" \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from "$CALLER_ADDRESS" 2>&1)

echo "$fetched_output"

# Extract the last 256 characters
pk=${fetched_output: -256}

echo "Fetched raw public key hex:"

echo "$pk"

echo "🛠️ Parse the fetched public keys and save them in Prover.toml..."
bash ../../scripts/parse_fetched_pk.sh "$pk" ./masking/Prover.toml

echo "💻 Running masking ZK circuit..."
cd ./masking
masking_output=$(nargo execute 2>&1)
if [ $? -ne 0 ]; then
    echo "❌ nargo execute failed:"
    echo "$masking_output"
    exit 1
fi

echo "$masking_output"
echo "✅ Masking ZK circuit executed: Masking done!"

bash ../../../scripts/parse_masked_model.sh "$masking_output" > /tmp/model${client_id}

# Generate proof
echo "👾 Generate a proof for correct masking..."
bb prove -b target/client${client_id}_masking.json -w target/client${client_id}_masking.gz -o target/proof





