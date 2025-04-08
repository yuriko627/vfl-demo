#!/usr/bin/env fish

set PKREGISTRY_ADDRESS $(cat /tmp/pkregistry_address)
set CL2TRAINVERIFIER_ADDRESS $(cat /tmp/client2trainverifier_address)
set PROOF $(od -An -v -t x1 ../client2_training/target/proof | tr -d ' \n')
set PK2_X $(cat /tmp/pk2_x)
set PK2_Y $(cat /tmp/pk2_y)

echo "😶‍🌫️ Start masking a model on Client2"

# Send transaction to verify the proof of correct training,
# and if this verification passes, register ECDH public key on chain
# trasaction signature: registerPublicKey(proofForClient2, address(v2), pk2_x, pk2_y, dummyInputs);
echo "Verify training proof and register ECDH public key on chain"
cast send $PKREGISTRY_ADDRESS \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x$PROOF \
  $CL2TRAINVERIFIER_ADDRESS \
  $PK2_X \
  $PK2_Y \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

# Just for the sake of demo, wait for the other two clients to register their public key
# We have to think this asynchronous coordination issue later
sleep 2

# Fectch 2 neigbor clients' public keys
echo "🔑 Fectch 2 neigbor clients' public keys (lower node: Client1, higher node: Client3)"

set fetched_output (cast call $PKREGISTRY_ADDRESS \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f 2>&1)

echo $fetched_output

# Extract the last 256 characters
set pk (string sub -s (math (string length $fetched_output) - 255) $fetched_output)

echo "✅ Fetched raw public key hex:"
echo $pk

# Parse $pk and write to Prover.toml
echo "🛠️ Parse public keys and save them in Prover.toml..."
fish ../../../parse_fetched_pk.fish \
  $pk \
  ./Prover.toml

set masking_output (nargo execute 2>&1)
echo $masking_output
echo "Masking ZKcircuit executed: Masking done"

# Parse the output masked model and pass it to publish_model.fish to publish it onchain
fish ../../../parse_masked_model.fish "$masking_output" > /tmp/model2

bb prove -b ./target/client2_masking.json -w ./target/client2_masking.gz -o ./target/proof
bb write_vk -b ./target/client2_masking.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/model_registry/src/Client2Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client2Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client2BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client2VerificationKey' \
    > $dest_path

echo "Client 2: masking done, verifier contract is ready to deploy"