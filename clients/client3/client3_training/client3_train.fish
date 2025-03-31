#!/usr/bin/env fish

echo "Start training a model on client3"

# Train a model and generate a proof
nargo execute
bb prove -b ./target/client3_training.json -w ./target/client3_training.gz -o ./target/proof
bb write_vk -b ./target/client3_training.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/pkregistry/src/Client3Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client3Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client3BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client3VerificationKey' \
    > $dest_path

echo "Client 3: training done, verifier contract is ready to deploy"

echo " Deploy 3 verifier contracts and PublickeyRegistry contract"

cd ../../../contracts/pkregistry/

forge script script/DeployPublicKeyRegistry.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80