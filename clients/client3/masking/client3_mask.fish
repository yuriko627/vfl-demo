#!/usr/bin/env fish

set PKREGISTRY_ADDRESS $(cat /tmp/pkregistry_address)
set CL3TRAINVERIFIER_ADDRESS $(cat /tmp/client3trainverifier_address)
set PROOF $(od -An -v -t x1 ../client3_training/target/proof | tr -d ' \n')
set PK3_X $(cat /tmp/pk3_x)
set PK3_Y $(cat /tmp/pk3_y)

echo "😶‍🌫️ Start masking a model on Client3"

# Send transaction to verify the proof of correct training,
# and if this verification passes, register ECDH public key on chain
# trasaction signature: registerPublicKey(proofForClient3, address(v3), pk3_x, pk3_y, dummyInputs);
echo "Verify training proof and register ECDH public key on chain"
cast send $PKREGISTRY_ADDRESS \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x$PROOF \
  $CL3TRAINVERIFIER_ADDRESS \
  $PK3_X \
  $PK3_Y \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356

# Just for the sake of demo, wait for the other two clients to register their public key
# We have to think this asynchronous coordination issue later
sleep 2

# Fectch 2 neigbor clients' public keys
echo "🔑 Fectch 2 neigbor clients' public keys (lower node: Client2, higher node: Client1)"

set fetched_output (cast call $PKREGISTRY_ADDRESS \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 2>&1)

echo $fetched_output

# Extract the last 256 characters
set pk (string sub -s (math (string length $fetched_output) - 255) $fetched_output)

echo "✅ Fetched raw public key hex:"
echo $pk

# Parse $pk and write to Prover.toml
echo "🛠️ Parse public keys and save them in Prover.toml..."
bash ../../../scripts/parse_fetched_pk.sh \
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
bash ../../../scripts/parse_masked_model.sh "$masking_output" > /tmp/model3

bb prove -b ./target/masking.json -w ./target/masking.gz -o ./target/proof
bb write_vk -b ./target/masking.json -o ./target/vk
bb contract

# Rename and copy verifier contract
set src_path ./target/contract.sol
set dest_path ../../../contracts/model_registry/src/Client3Verifier.sol

cat $src_path | \
    string replace -a --regex 'UltraVerifier\b' 'Client3Verifier' | \
    string replace -a --regex 'BaseUltraVerifier\b' 'Client3BaseVerifier' | \
    string replace -a --regex 'UltraVerificationKey\b' 'Client3VerificationKey' \
    > $dest_path

echo "Client 3: masking done, verifier contract is ready to deploy"