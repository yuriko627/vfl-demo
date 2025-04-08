#!/usr/bin/env fish

set MODELREGISTRY_ADDRESS $(cat /tmp/modelregistry_address)
set CL2MASKVERIFIER_ADDRESS $(cat /tmp/client2maskverifier_address)
set PROOF $(od -An -v -t x1 ../client2_masking/target/proof | tr -d ' \n')
set MODEL2 $(cat /tmp/model2)

echo "Masked model to be included in the tx:"
echo $MODEL2

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
  $CL2MASKVERIFIER_ADDRESS \
  $MODEL2 \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

echo "Successfully published a masked model from Client2"