#!/usr/bin/env bash
set -e

# Deploy 3 verifier contracts and PublicKeyRegistry contract - this will be done at the beginning in the server pane

for client_id in 1 2 3; do
(   # Subshell for each client runs in the background
    # Generate verification key and solidity verifier contract
    echo "📑 Generating training verifier contract for Client ${client_id}..."
    cd ../clients/client${client_id}/training
    nargo compile
    bb write_vk -b "./target/client${client_id}_training.json" -o ./target/vk
    bb contract

    # Rename some variables in the auto-generated verifier contract
    src_path=./target/contract.sol
    dest_path=../../../contracts/pk_registry/src/Client${client_id}Verifier.sol

    cat "$src_path" | \
    sed -e "s/UltraVerifier/Client${client_id}Verifier/g" | \
    sed -e "s/BaseUltraVerifier/Client${client_id}BaseVerifier/g" | \
    sed -e "s/UltraVerificationKey/Client${client_id}VerificationKey/g" \
    > "$dest_path"

    echo "✅ Client ${client_id} training verifier contract is ready to deploy"

) &
done
# Wait for all background tasks to complete
wait

cd ../contracts/pk_registry/
PRIVATE_KEY=$(bash ../../scripts/extract_eth_accounts.sh privatekey 4)

echo "🚀 Deploying PublicKeyRegistry contract..."
forge script script/DeployPublicKeyRegistry.s.sol \
    --rpc-url http://localhost:8545 --broadcast \
    --private-key $PRIVATE_KEY

# Extract contract addresses from output log
grep 'Client1Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1trainverifier_address
grep 'Client2Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2trainverifier_address
grep 'Client3Verifier' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3trainverifier_address
grep 'PublicKeyRegistry' /tmp/deploy_pk_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/pkregistry_address

echo "✅ 3 training verifier contracts and PublicKeyRegistry contract has been deployed"