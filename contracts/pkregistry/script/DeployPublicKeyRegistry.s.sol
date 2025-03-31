// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/PublicKeyRegistry.sol";
import "../src/Client1Verifier.sol";
import "../src/Client2Verifier.sol";
import "../src/Client3Verifier.sol";

contract DeployScript is Script {
    PublicKeyRegistry public publicKeyRegistry;
    Client1Verifier public verifier1;
    Client2Verifier public verifier2;
    Client3Verifier public verifier3;

    function run() public {
        vm.startBroadcast();

        // Deploy verifier contracts
        verifier1 = new Client1Verifier();
        verifier2 = new Client2Verifier();
        verifier3 = new Client3Verifier();

        console.log("Client1Verifier deployed at:", address(verifier1));
        console.log("Client2Verifier deployed at:", address(verifier2));
        console.log("Client3Verifier deployed at:", address(verifier3));

        // Deploy PublicKeyRegistry (no verifier needed at deployment)
        publicKeyRegistry = new PublicKeyRegistry();
        console.log("PublicKeyRegistry deployed at:", address(publicKeyRegistry));

        vm.stopBroadcast();
    }
}
