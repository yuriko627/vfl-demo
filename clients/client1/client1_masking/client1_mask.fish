#!/usr/bin/env fish

set PKREGISTRY_ADDRESS $(cat /tmp/pkregistry_address)
set CL1TRAINVERIFIER_ADDRESS $(cat /tmp/client1trainverifier_address)
set PROOF $(od -An -v -t x1 ../client1_training/target/proof | tr -d ' \n')
set PK1_X $(cat /tmp/pk1_x)
set PK1_Y $(cat /tmp/pk1_y)

echo "😶‍🌫️ Start masking a model on Client1"

# Send transaction to verify the proof of correct training,
# and if this verification passes, register ECDH public key on chain
# trasaction signature: registerPublicKey(proofForClient1, address(v1), pk1_x, pk1_y, dummyInputs);
echo "Verify training proof and register ECDH public key on chain"
cast send $PKREGISTRY_ADDRESS \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x$PROOF \
  $CL1TRAINVERIFIER_ADDRESS \
  $PK1_X \
  $PK1_Y \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

# Just for the sake of demo, wait for the other two clients to register their public key
# We have to think this asynchronous coordination issue later
sleep 2

# Fectch 2 neigbor clients' public keys
echo "🔑 Fectch 2 neigbor clients' public keys (lower node: Client3, higher node: Client2)"

set fetched_output (cast call $PKREGISTRY_ADDRESS \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 2>&1)

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

if test $status -ne 0
    echo "❌　nargo execute failed:"
    echo $masking_output
end

echo $masking_output
echo "Masking ZKcircuit executed: Masking done"

# Parse the output masked model and pass it to publish_model.fish to publish it onchain
bash ../../../parse_masked_model.sh "$masking_output" > /tmp/model1

bb prove -b ./target/client1_masking.json -w ./target/client1_masking.gz -o ./target/proof
bb write_vk -b ./target/client1_masking.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/model_registry/src/Client1Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client1Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client1BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client1VerificationKey' \
    > $dest_path

echo "Client 1: masking done, verifier contract is ready to deploy"
