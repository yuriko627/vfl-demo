#!/usr/bin/env bash

echo "Deploy 3 verifier contracts and PublicKeyRegistry contract"

cd ../contracts/pk_registry/

# TODO: change hardcoded priv_key value from Anvil
forge script script/DeployPublicKeyRegistry.s.sol \
    --rpc-url http://localhost:8545 --broadcast \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Extract contract addresses from output log
grep 'Client1Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1trainverifier_address
grep 'Client2Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2trainverifier_address
grep 'Client3Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3trainverifier_address
grep 'PublicKeyRegistry' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/pkregistry_address
