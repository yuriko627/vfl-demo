// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/PublicKeyRegistry.sol";
import "../src/Verifier1.sol";

contract PublicKeyRegistryScript is Script {
    PublicKeyRegistry public publickeyregistry;
    UltraVerifier public verifier;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        verifier = new UltraVerifier();
        publickeyregistry = new PublicKeyRegistry(address(verifier));

        vm.stopBroadcast();
    }
}
