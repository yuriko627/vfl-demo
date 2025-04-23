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

    address public server;

    // Mapping from client address to their local Model
    mapping(address => MultiClassTrainedModel) public registeredLocalModels;

    // The global model submitted by the server
    MultiClassTrainedModel public globalModel;
    bool public globalModelRegistered;

    // Ordered list of registered clients
    address[] public registeredClients;

    constructor(address _server) {
        require(_server != address(0), "Server address cannot be zero");
        server = _server;
    }

    function registerLocalModel(
        bytes calldata proof,
        address verifierAddress,
        MultiClassTrainedModel calldata model,
        bytes32[] calldata publicInputs
    ) external {
        require(registeredLocalModels[msg.sender].n_samples == 0, "This model is already registered");
        require(verifierAddress != address(0), "Invalid verifier address");

        bool isValid = IVerifier(verifierAddress).verify(proof, publicInputs);
        require(isValid, "Invalid ZK proof for masking");

        registeredLocalModels[msg.sender] = model;
        registeredClients.push(msg.sender);
    }

    function getModels() external view returns (MultiClassTrainedModel[3] memory models) {
        // TODO: think whether we should wait for/expect all the clinets to register their models
        uint256 numregisteredLocalModels = registeredClients.length;
        require(numregisteredLocalModels == 3, "Not all the users registered models yet");

        for (uint256 i = 0; i < numregisteredLocalModels; i++) {
            models[i] = registeredLocalModels[registeredClients[i]];
        }
        return models;
    }

    function registerGlobalModel(bytes calldata proof, address verifierAddress, MultiClassTrainedModel calldata model, bytes32[] calldata publicInputs) external {
        require(msg.sender == server, "Only the server can register the global model");
        require(!globalModelRegistered, "Global model already registered");
        require(verifierAddress != address(0), "Invalid verifier address");

        bool isValid = IVerifier(verifierAddress).verify(proof, publicInputs);
        require(isValid, "Invalid ZK proof for masking");

        globalModel = model;
        globalModelRegistered = true;
    }

    function getGlobalModel() external view returns (MultiClassTrainedModel memory) {
        require(globalModelRegistered, "Global model not registered yet");
        return globalModel;
    }

}
