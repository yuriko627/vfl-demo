#!/usr/bin/env fish

set MODELREGISTRY_ADDRESS $(cat /tmp/modelregistry_address)


echo "Start aggregating locally trained models"

# Fectch 2 neigbor clients' public keys
echo "Fectch masked models published on chain"

set fetched_models (cast call $MODELREGISTRY_ADDRESS \
  "getModels()(((uint256[4],uint256)[3], uint256)[3])" \
  --rpc-url http://localhost:8545 \
  --from 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 2>&1)

echo "✅ Fetched raw models:"
echo $fetched_models

bash ../scripts/parse_fetched_model.sh "$fetched_models" > Prover.toml

nargo execute > finaloutput.toml