#!/usr/bin/env fish

set MODELREGISTRY_ADDRESS $(cat /tmp/modelregistry_address)
set CL1MASKVERIFIER_ADDRESS $(cat /tmp/client1maskverifier_address)
set PROOF $(od -An -v -t x1 ../client1_masking/target/proof | tr -d ' \n')
set MODEL1 $(cat /tmp/model1)

echo "Masked model to be included in the tx:"
echo $MODEL1

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
  $CL1MASKVERIFIER_ADDRESS \
  $MODEL1 \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

echo "Successfully published a masked model from Client1"