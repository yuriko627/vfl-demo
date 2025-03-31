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

    IVerifier public verifier;

    // Mapping from client address to their PublicKey
    mapping(address => PublicKey) public publicKeys;

    // Ordered list of registered clients
    address[] public registeredClients;

    function registerPublicKey(
        bytes calldata proof,
        address verifierAddress,
        bytes32 pk_x,
        bytes32 pk_y,
        bytes32[] calldata publicInputs
    ) external {
        require(publicKeys[msg.sender].pk_x == bytes32(0) && publicKeys[msg.sender].pk_y == bytes32(0), "This public key is already registered");
        require(verifierAddress != address(0), "Invalid verifier address");

        bool isValid = IVerifier(verifierAddress).verify(proof, publicInputs);
        require(isValid, "Invalid ZK proof");

        publicKeys[msg.sender] = PublicKey(pk_x, pk_y);
        registeredClients.push(msg.sender);
    }

    function getNeighborPublicKeys() external view returns (PublicKey memory lowerNeighborPublicKey, PublicKey memory higherNeighborPublicKey) {
        uint256 total = registeredClients.length;
        require(total >= 2, "Not enough users to determine neighbors");

        uint256 myId = total;
        for (uint256 i = 0; i < total; i++) {
            if (registeredClients[i] == msg.sender) {
                myId = uint256(i);
                break;
            }
        }

        require(myId != total, "Sender not registered");

        // Index of circular neighbors
        // e.g. For 0, lower: 2 &  higher 1
        // e.g. For 1, lower: 0 &  higher 2
        // e.g. For 2, lower: 1 &  higher 0
        uint256 lowerId = (myId == 0) ? (total - 1) : (myId - 1);
        uint256 higherId = (myId + 1) % total;

        lowerNeighborPublicKey = publicKeys[registeredClients[lowerId]];
        higherNeighborPublicKey = publicKeys[registeredClients[higherId]];

        return (lowerNeighborPublicKey, higherNeighborPublicKey);
    }

}
