// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVerifier {
    function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool);
}


contract PublicKeyRegistry {
    struct PublicKey {
        bytes32 pk_x;
        bytes32 pk_y;
    }

    mapping(address => PublicKey) public publicKeys;
    address[] public registeredUsers;

    IVerifier public verifier;

    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    function registerWithProof(
        bytes32 pk_x,
        bytes32 pk_y,
        bytes calldata proof,
        bytes32[] calldata publicInputs
    ) external {
        require(publicKeys[msg.sender].pk_x == bytes32(0) && publicKeys[msg.sender].pk_y == bytes32(0), "Already registered");

        bool isValid = verifier.verify(proof, publicInputs);
        require(isValid, "Invalid ZK proof");

        publicKeys[msg.sender] = PublicKey(pk_x, pk_y);
        registeredUsers.push(msg.sender);
    }

    function getAllPublicKeys() external view returns (address[] memory, PublicKey[] memory) {
        uint len = registeredUsers.length;
        PublicKey[] memory keys = new PublicKey[](len);
        for (uint i = 0; i < len; i++) {
            keys[i] = publicKeys[registeredUsers[i]];
        }
        return (registeredUsers, keys);
    }
}
