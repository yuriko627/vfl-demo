// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVerifier {
    function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool);
}

contract ModelRegistry {
    struct TrainedModelPerClass {
    uint256[4] weights;
    uint256 bias;
    }

    struct MultiClassTrainedModel {
        TrainedModelPerClass[3] models;
        uint256 n_samples;
    }

    IVerifier public verifier;

    // Mapping from client address to their Model
    mapping(address => MultiClassTrainedModel) public registeredModels;

    // Ordered list of registered clients
    address[] public registeredClients;

    function registerModel(
        bytes calldata proof,
        address verifierAddress,
        MultiClassTrainedModel calldata model,
        bytes32[] calldata publicInputs
    ) external {
        require(registeredModels[msg.sender].n_samples == 0, "This model is already registered");
        require(verifierAddress != address(0), "Invalid verifier address");

        bool isValid = IVerifier(verifierAddress).verify(proof, publicInputs);
        require(isValid, "Invalid ZK proof for masking");

        registeredModels[msg.sender] = model;
        registeredClients.push(msg.sender);
    }

    function getModels() external view returns (MultiClassTrainedModel[] memory models) {
        // TODO: think whether we should wait for/expect all the clinets to register their models
        uint256 numRegisteredModels = registeredClients.length;
        require(numRegisteredModels == 3, "Not all the users registered models yet");

        models = new MultiClassTrainedModel[](numRegisteredModels);
        for (uint256 i = 0; i < numRegisteredModels; i++) {
            models[i] = registeredModels[registeredClients[i]];
        }
        return models;
    }

}
