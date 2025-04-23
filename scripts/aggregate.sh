#!/usr/bin/env bash

set -e

trap 'echo "❌ Error on line $LINENO. Exiting."; exit 1' ERR

MODELREGISTRY_ADDRESS=$(cat /tmp/modelregistry_address)
CALLER_ADDRESS=$(bash ../scripts/extract_eth_accounts.sh address 5)

echo "🌻 Start aggregating local models"

# Fetch 2 neighbor clients' public keys
echo "📝 Send transaction to fetch masked models published on chain"

FETCHED_MODELS=$(cast call "$MODELREGISTRY_ADDRESS" \
  "getModels()(((uint256[4],uint256)[3], uint256)[3])" \
  --rpc-url http://localhost:8545 \
  --from $CALLER_ADDRESS 2>&1)

echo $FETCHED_MODELS

bash ../scripts/parse_fetched_model.sh "$FETCHED_MODELS" > Prover.toml

echo "💻 Running aggregation ZK circuit..."
aggregation_output=$(nargo execute 2>&1)
if [ $? -ne 0 ]; then
    echo "❌ nargo execute failed:"
    echo "$masking_output"
    exit 1
fi

echo "$aggregation_output"  > ../test/finaloutput.toml
echo "✅ Aggregation ZK circuit executed: Aggregation done!"

bash ../scripts/parse_masked_model.sh "$aggregation_output" > /tmp/global_model

# Generate proof
echo "👾 Generate a proof for correct aggregation..."
bb prove -b target/aggregation.json -w target/aggregation.gz -o target/proof

MODELREGISTRY_ADDRESS=$(cat /tmp/modelregistry_address)
VERIFIER_ADDRESS=$(cat /tmp/serververifier_address)
MODEL=$(cat /tmp/global_model)
PROOF=$(od -An -v -t x1 ./target/proof | tr -d ' \n')
PRIVATE_KEY=$(bash ../scripts/extract_eth_accounts.sh privatekey 5)

echo "Global model to be included in the tx sent from the server:"
echo "${MODEL}"

# Send transaction to verify the proof of correct masking,
# and if this verification passes, publish the masked model
# transaction signature:
# registerLocalModel(
#	 bytes calldata proof,
#	 address verifierAddress,
#	 MultiClassTrainedModel calldata model,
#	 bytes32[] calldata publicInputs)
echo "📝 Send transaction to publish a global model"
echo "🧾 Transaction Receipt:"
cast send "${MODELREGISTRY_ADDRESS}" \
  "registerGlobalModel(bytes,address,((uint256[4],uint256)[3],uint256),bytes32[])" \
  0x${PROOF} \
  "${VERIFIER_ADDRESS}" \
  "${MODEL}" \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key "${PRIVATE_KEY}"

if [ $? -eq 0 ]; then
  echo "Successfully published a global model from the server"
else
  echo "❌ Failed to publish a global model from the server"
fi
