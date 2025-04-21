#!/usr/bin/env bash

echo "Deploy 3 verifier contracts and ModelRegistry contract"
cd ../contracts/model_registry/
PRIVATE_KEY=$(bash ../../scripts/extract_eth_accounts.sh privatekey 4)

# TODO: change hardcoded priv_key value from Anvil
forge script script/DeployModelRegistry.s.sol \
    --rpc-url http://localhost:8545 --broadcast \
    --private-key $PRIVATE_KEY

# Extract contract addresses
grep 'Client1Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1maskverifier_address
grep 'Client2Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2maskverifier_address
grep 'Client3Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3maskverifier_address
grep 'ModelRegistry'   /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/modelregistry_address
