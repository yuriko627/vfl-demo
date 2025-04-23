// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ModelRegistry} from "../src/ModelRegistry.sol";
import "../src/Client1Verifier.sol";
import "../src/Client2Verifier.sol";
import "../src/Client3Verifier.sol";
import "../src/ServerVerifier.sol";

contract DeployScript is Script {
    ModelRegistry public modelRegistry;
    Client1Verifier public verifier1;
    Client2Verifier public verifier2;
    Client3Verifier public verifier3;
    ServerVerifier public verifier4;

    function run() public {
        vm.startBroadcast();

        // Deploy verifier contracts
        verifier1 = new Client1Verifier();
        verifier2 = new Client2Verifier();
        verifier3 = new Client3Verifier();
        verifier4 = new ServerVerifier();

        console.log("Client1Verifier deployed at:", address(verifier1));
        console.log("Client2Verifier deployed at:", address(verifier2));
        console.log("Client3Verifier deployed at:", address(verifier3));
        console.log("ServerVerifier deployed at:", address(verifier4));

        modelRegistry = new ModelRegistry(0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc);
        console.log("ModelRegistry deployed at:", address(modelRegistry));

        vm.stopBroadcast();
    }
}
