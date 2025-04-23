#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  echo "Usage: ./publish_model.sh <client_id>"
  exit 1
fi

CLIENT_ID=$1
MODELREGISTRY_ADDRESS=$(cat /tmp/modelregistry_address)
VERIFIER_ADDRESS=$(cat /tmp/client${CLIENT_ID}maskverifier_address)
MODEL=$(cat /tmp/model${CLIENT_ID})
PROOF=$(od -An -v -t x1 ./masking/target/proof | tr -d ' \n')
PRIVATE_KEY=$(bash ../../scripts/extract_eth_accounts.sh privatekey ${CLIENT_ID})

echo "Masked model to be included in the tx (Client${CLIENT_ID}):"
echo "${MODEL}"

# Send transaction to verify the proof of correct masking,
# and if this verification passes, publish the masked model
# transaction signature:
# registerLocalModel(
#	 bytes calldata proof,
#	 address verifierAddress,
#	 MultiClassTrainedModel calldata model,
#	 bytes32[] calldata publicInputs)
echo "📝 Send transaction to publish masked models"
echo "🧾 Transaction Receipt:"
cast send "${MODELREGISTRY_ADDRESS}" \
  "registerLocalModel(bytes,address,((uint256[4],uint256)[3],uint256),bytes32[])" \
  0x${PROOF} \
  "${VERIFIER_ADDRESS}" \
  "${MODEL}" \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key "${PRIVATE_KEY}"

if [ $? -eq 0 ]; then
  echo "Successfully published a masked model from Client${CLIENT_ID}"
else
  echo "❌ Failed to publish masked model from Client${CLIENT_ID}"
fi

