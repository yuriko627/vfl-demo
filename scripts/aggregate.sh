#!/usr/bin/env bash

MODELREGISTRY_ADDRESS=$(cat /tmp/modelregistry_address)
CALLER_ADDRESS=$(bash ../scripts/extract_eth_accounts.sh address 5)

echo "Start aggregating locally trained models"

# Fetch 2 neighbor clients' public keys
echo "Fetch masked models published on chain"

FETCHED_MODELS=$(cast call "$MODELREGISTRY_ADDRESS" \
  "getModels()(((uint256[4],uint256)[3], uint256)[3])" \
  --rpc-url http://localhost:8545 \
  --from $CALLER_ADDRESS 2>&1)

echo "Fetched raw models:"
echo "$FETCHED_MODELS"

bash ../scripts/parse_fetched_model.sh "$FETCHED_MODELS" > Prover.toml

nargo execute > finaloutput.toml
