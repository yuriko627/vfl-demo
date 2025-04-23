#!/usr/bin/env bash

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
CALLER_ADDRESS=$(bash ../../scripts/extract_eth_accounts.sh address ${client_id})

echo "👻 Start masking a model on Client${client_id}"

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





