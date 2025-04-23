
set -e

usage() {
    echo "Usage: fetch_global_model.sh <client_id>"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

client_id=$1


MODELREGISTRY_ADDRESS=$(cat /tmp/modelregistry_address)
CALLER_ADDRESS=$(bash ../../scripts/extract_eth_accounts.sh address ${client_id})
echo "🌿 Fetch global model from blockchain"

# Fetch 2 neighbor clients' public keys
echo "📝 Send transaction to fetch a global model published on chain"

FETCHED_GLOBAL_MODEL=$(cast call "$MODELREGISTRY_ADDRESS" \
  "getGlobalModel()((uint256[4],uint256)[3], uint256)" \
  --rpc-url http://localhost:8545 \
  --from $CALLER_ADDRESS 2>&1)

if [ $? -eq 0 ]; then
  echo "Successfully fetched a global model at Client${client_id}"
else
  echo "❌ Failed to fetch a global model at Client${client_id}"
fi

echo "Fetched raw models:"
echo $FETCHED_GLOBAL_MODEL