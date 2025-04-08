#!/usr/bin/env fish

set MODELREGISTRY_ADDRESS $(cat /tmp/modelregistry_address)
set CL3MASKVERIFIER_ADDRESS $(cat /tmp/client3maskverifier_address)
set PROOF $(od -An -v -t x1 ../client3_masking/target/proof | tr -d ' \n')
set MODEL3 $(cat /tmp/model3)

echo "Masked model to be included in the tx:"
echo $MODEL3

# Send transaction to verify the proof of correct masking,
# and if this verification passes, publish the masked model
# trasaction signature:
# registerModel(
#	 bytes calldata proof,
#	 address verifierAddress,
#	 MultiClassTrainedModel calldata model,
#	 bytes32[] calldata publicInputs)
echo "Verify masking proof and publish the model on chain"
cast send $MODELREGISTRY_ADDRESS \
  "registerModel(bytes,address,((uint256[4],uint256)[3],uint256),bytes32[])" \
  0x$PROOF \
  $CL3MASKVERIFIER_ADDRESS \
  $MODEL3 \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356

echo "Successfully published a masked model from Client1"