#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: mask.sh <client_id>"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

CLIENT_ID=$1

# Derive paths based on client ID
PKREGISTRY_ADDRESS=$(cat /tmp/pkregistry_address)
TRAIN_VERIFIER_ADDRESS=$(cat /tmp/client${CLIENT_ID}trainverifier_address)
PROOF=$(od -An -v -t x1 ../training/target/proof | tr -d ' \n')
PK_X=$(cat /tmp/pk${CLIENT_ID}_x)
PK_Y=$(cat /tmp/pk${CLIENT_ID}_y)
PRIVATE_KEY=$(bash ../../../scripts/extract_eth_accounts.sh privatekey ${CLIENT_ID})
CALLER_ADDRESS=$(bash ../../../scripts/extract_eth_accounts.sh address ${CLIENT_ID})

echo "😶‍🌫️ Start masking a model on Client${CLIENT_ID}"

echo "Verify training proof and register ECDH public key on chain"
cast send "$PKREGISTRY_ADDRESS" \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x"$PROOF" \
  "$TRAIN_VERIFIER_ADDRESS" \
  "$PK_X" \
  "$PK_Y" \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key "$PRIVATE_KEY"

# Demo wait — will need coordination solution in future
sleep 2

echo "🔑 Fetch 2 neighbor clients' public keys"

fetched_output=$(cast call "$PKREGISTRY_ADDRESS" \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from "$CALLER_ADDRESS" 2>&1)

echo "$fetched_output"

# Extract the last 256 characters
pk=${fetched_output: -256}

echo "✅ Fetched raw public key hex:"
echo "$pk"

echo "🛠️ Parse public keys and save them in Prover.toml..."
bash ../../../scripts/parse_fetched_pk.sh "$pk" ./Prover.toml

echo "🚀 Running masking ZK circuit..."
masking_output=$(nargo execute 2>&1)
if [ $? -ne 0 ]; then
    echo "❌ nargo execute failed:"
    echo "$masking_output"
    exit 1
fi

echo "$masking_output"
echo "Masking ZKcircuit executed: Masking done"

bash ../../../scripts/parse_masked_model.sh "$masking_output" > /tmp/model${CLIENT_ID}

bb prove -b ./target/client${CLIENT_ID}_masking.json -w ./target/client${CLIENT_ID}_masking.gz -o ./target/proof
bb write_vk -b ./target/client${CLIENT_ID}_masking.json -o ./target/vk
bb contract

src_path=./target/contract.sol
dest_path=../../../contracts/model_registry/src/Client${CLIENT_ID}Verifier.sol

cat "$src_path" | \
  sed -e "s/UltraVerifier/Client${CLIENT_ID}Verifier/g" | \
  sed -e "s/BaseUltraVerifier/Client${CLIENT_ID}BaseVerifier/g" | \
  sed -e "s/UltraVerificationKey/Client${CLIENT_ID}VerificationKey/g" \
  > "$dest_path"

echo "✅ Client ${CLIENT_ID}: masking done, verifier contract is ready to deploy"


