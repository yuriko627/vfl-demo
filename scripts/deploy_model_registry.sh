#!/usr/bin/env bash
set -e

# Deploy 3 verifier contracts and ModelRegistry contract - this will be done at the beginning in the server pane

for client_id in 1 2 3; do
(   # Subshell for each client runs in the background
    # Generate verification key and solidity verifier contract
    echo "📑 Generating masking verifier contract for Client ${client_id}..."
    cd ../clients/client${client_id}/masking
    bb write_vk -b "./target/client${client_id}_masking.json" -o ./target/vk
    bb contract

    # Rename some variables in the auto-generated verifier contract
    src_path=./target/contract.sol
    dest_path=../../../contracts/model_registry/src/Client${client_id}Verifier.sol

    cat "$src_path" | \
    sed -e "s/UltraVerifier/Client${client_id}Verifier/g" | \
    sed -e "s/BaseUltraVerifier/Client${client_id}BaseVerifier/g" | \
    sed -e "s/UltraVerificationKey/Client${client_id}VerificationKey/g" \
    > "$dest_path"

    echo "✅ Client ${client_id} masking verifier contract is ready to deploy"

) &
done
# Wait for all background tasks to complete
wait

echo "📑 Generating aggregation verifier contract for the Server..."
cd ../server
nargo compile
bb write_vk -b "./target/aggregation.json" -o ./target/vk
bb contract

# Rename some variables in the auto-generated verifier contract
src_path=./target/contract.sol
dest_path=../contracts/model_registry/src/ServerVerifier.sol

cat "$src_path" | \
sed -e "s/UltraVerifier/ServerVerifier/g" | \
sed -e "s/BaseUltraVerifier/ServerBaseVerifier/g" | \
sed -e "s/UltraVerificationKey/ServrVerificationKey/g" \
> "$dest_path"

echo "✅ Server aggregation verifier contract is ready to deploy"

cd ../contracts/model_registry/
PRIVATE_KEY=$(bash ../../scripts/extract_eth_accounts.sh privatekey 4)

echo "🚀 Deploying ModelRegistry contract..."
forge script script/DeployModelRegistry.s.sol \
    --rpc-url http://localhost:8545 --broadcast \
    --private-key $PRIVATE_KEY

# Extract contract addresses
grep 'Client1Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1maskverifier_address
grep 'Client2Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2maskverifier_address
grep 'Client3Verifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3maskverifier_address
grep 'ServerVerifier' /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/serververifier_address
grep 'ModelRegistry'  /tmp/deploy_model_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/modelregistry_address

echo "✅ 4 masking verifier contracts and ModelRegistry contract has been deployed"