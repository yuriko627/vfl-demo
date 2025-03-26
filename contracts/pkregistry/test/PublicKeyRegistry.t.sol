// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../src/PublicKeyRegistry.sol";
import "../src/Verifier1.sol";

contract PublicKeyRegistryTest is Test {
    PublicKeyRegistry registry;
    UltraVerifier verifier;

    address client1 = address(0x1);
    address client2 = address(0x2);
    address client3 = address(0x3);

    function setUp() public {
        verifier = new UltraVerifier();
        registry = new PublicKeyRegistry(address(verifier));
    }

    function testClientsRegisterWithProofs() public {
        bytes32 pk1_x = 0x0bb77a6ad63e739b4eacb2e09d6277c12ab8d8010534e0b62893f3f6bb957051;
        bytes32 pk1_y = 0x25797203f7a0b24925572e1cd16bf9edfce0051fb9e133774b3c257a872d7d8b;
        string memory key2 = "client2_pubkey";
        string memory key3 = "client3_pubkey";

        // Dummy proof and inputs (replace with real ones later)
        bytes memory dummyProof = hex"0c00fbd4d147e7787f345acf607f273a460eb542b057030cb8a3a22a166327610e25168619e4b2492f9867bbed9d1bba0b08a52b33b250d8e0aa7c8df6ca8ef819b29fa791c9001f592ad49013c1155d07ea96ac711b1c298a353fb617aed6a604d2a9286c59b7f598be8e2a52a5ea24d50eca9cd68abe0cb5b193bb887083b916a02558f08aa875c43d2e3f751711e06d03dcc839006a0b01ac4ade7d709a6b21a7fb5ef92bbef412b56c5a8240c47d746236f28852dacb1d49ac041089d5b116c69371450e854791967d2e966ae8c40148c5a6abfc4770294d1d03ee2dd0270cd3a7efb78503e5698fe9c85164b00e453aafb948db604dd0386f4f2f76e5720aa08a90f90a0ba3da36830a30d1c03fb3621b2d03dd994bcec7694de1a236682800ca1c933d2bc032f4ea33722358f5e9259d040d3f45bd2ef00aa053eb219e24049c89489116a118ee0e39df3516df08c0c6c13c9b2ecb08137bc21274d8311c1fe1701b258f33b8694a518256be1951080bf4a47963918540c4da5dca27321839217329298773c33cac6016bec72b83512d04aedc390afd0af0f75aeb5f9b0779f2ad1d26138286bc98cf50ba6665332cf9af959aca039bc774d2e0adb12c14b4468675418bd31eaa8403e7be13f0e33e7d88ae621487432e3210a9827e1f06d5614ef167cbd3cc0ff8243ca19a17bee6ad450919b372b87d4f2a6d7bf6332442b31226679191d47496cfd594a841eaa3a108b7b2797838a7d621f6b9a95a11692bfc8da49f178180081de6622c3dc241137849d6594863ce64f16b0207482609107d9b6dc3326c36fcef179390ddd5a76aa076b1b47ee27c008e5a757b211e8890f0590812d107471aed9e6d956d077ae2b9e222ff2dfafc9da3f2633c5229667f7c415e24724e6339382d86fc335a74de983eeeba5d47df0e5149cf3e462830a3a958b27fc47e4e6f1a2365f1f4021365a40ffaddca74aeee8128b36d910cb7e4f5deafa3c7fc7520756f6836e3e03afaabf73609ad5c0f7016bb307a81163e6d4fc54bd45a4f6e5a119f3a1382da688ccf95f8e870e7e0be0ae9fc5ace0b69c2535f9cdc734d5ba84de7a5135418a949436839426d2368c7a2b1c6d5cd1b2300c5216cc51b3279ba10ea2f4dd8347cdb281bd398f3221d969bce40cd3d18ed3158674d5d4a1de78f88e8ca65948642aa9449168224c880cd3a1930b03219e6c2651a7e36d7102dbf92b0e2f6516351e0a467e163243ac41356884bf7b31563b2381f1b454d0ba239dfcc64b8f92ac374f2b76e3d74b4083f9765370e6528926c767677b8faf3b6ec0f9ab34b72fb6de6935019a925c39d62672bcf0d2307b4ae54ac2d44cf13561ab2843db24eccbb41f63c4c1a9fda5586230dd0d63601683f74f09f37bb0bbdcd31927c9a04437e758d4414c8026ca2a23e977bb57024f0afc443a1137eff986c4458eecc66b8f50b9cdb03b21f41f7a2b31321215c1f2439d29c29e05df426b8d1e68376831cee2cbc5f440a60143b36c90f75f27e2f68ab290a140b540931762db291b45869e5cea6c57ee76d11dbb940737103630062b4df16c9b18b66f3dbad2669c54905b59243ee6093482a122781c9f3ee542903610374af83dd5e270c9c78f73247d4155b70e36314c9e0a77bb27ee342fa0d4e5a9aed6e6de92913dd348e9d183ce59748aec5f81299959555fe38f58b031eea45eee119769f3230d421e6128db80c8081bde8188f85bcd4cdda0110d3592feb9756719256dfae49234dc9ba24a45285b4c25dfbf569baaf64e0fc0cf9970af2ebff333d350e8587c90b4d719bf374abeb784f9cb298fb43a8830b7085d20c63d944360287b6fbcf6fec54da5d7eb4f13c48d1ce593596ec62d0e83b7ab60c066c0141968dc0aa8c880469faa156c271092bf8113a0405b6af1eacc4f90f11bdce23e73de7e18c1a7c46137c2051321f0b93b2a018ccc771c7fda14764042359b977dae8f097953773336af195cc590844a2d4c095b8eeb13fd96962ac5a04915658ed625923e604246a40e5b2ea57bd95697d27a213d20ec221417df4af162d41ace10d61d9ef211b57985b28657ea6ce789f481efff94e39fd09993d050021e2cff392df2b82fd8558bc06aad60b35d284907f9be0a0325021d92c1bae242f0503d44140eb7845b8ca6de8103648db32c28056b19813b3318b38f744421fc67e430e1b8e8e2742bbe9458102501d09ef17a0ec2585836ae5b7904af42125be48022a335bcd9e70e75dac18f90c58b4edcecadf36f6656c02b247c0503a27f3deb842c7acaf9c3f5596cf317fb96020e2d98d95971c9d96374e6112899d11a9dab050313318ad186c55bf7627c9b589d9c91e35be7a9a6ba84e12bbdfe006856c6af7ee1e517cb7dabd50e9d6a6325b7ca836156bb89413d20171aa0cac2c34d6bdf16cdd348f1cf732b419606d599fe0464b9ab9f635ad96adfb4faa191fc11d1c684b137d7986204d02653baf50bc4b8cc0541a1525db059f6c8da8dc0009f2dc1850b4eca467e7a60415e082c5ae38ebb0c963550a8a49e713e735c63011fc3e77544a83bbc84ec81418921bcd56da72a80ca7431f0582028439f8461b844417641c1ffb729bf431b67a381cecc26b3c07ccc5217419174c4164deda0412e9fd6ca61ab2fa6e208745f4e2190314e18c7cccd610956420fce679a0122cbd69879c07f7b9fe3a32aaa25fbe9364d735e9eca31b0b051370629703c2bf25039a9eea38349749b5ff177d4942b09e65a1fee2bfef7430e0ca34578de56b1d49cbb6386871749531cb845832c6cdd7f40e13d8dcc3dd5cae2406181808172c5c7f5bfe220222d4efdea9d1f135caf6e552b560c6ca67cebf2efc7bfe699123e645944e57d4b9eeeaf9bde49ab2242389d3fa863c879a3f3e378aa7774f3a13d345c2cd6f912bff3538151438d86092ab3522bd61503f1673d3c6cb7979db137d3e07613a120d3b189f0186f805cffb85abedb3e681d73323dc2682dee786";
        bytes32[] memory dummyInputs;

        vm.prank(client1);
        registry.registerWithProof(pk1_x, pk1_y, dummyProof, dummyInputs);

        vm.prank(client2);
        registry.registerWithProof(pk1_x, pk1_y, dummyProof, dummyInputs);

        vm.prank(client3);
        registry.registerWithProof(pk1_x, pk1_y, dummyProof, dummyInputs);

        (address[] memory addrs, PublicKeyRegistry.PublicKey[] memory keys) = registry.getAllPublicKeys();

        assertEq(addrs.length, 3);
        assertEq(keys.length, 3);


        // assertEq(keys[0], pk1_x);
        // assertEq(keys[1], key2);
        // assertEq(keys[2], key3);

        for (uint i = 0; i < keys.length; i++) {
            console.log("Client %s registered key:", i + 1);
            console.logBytes32(keys[i].pk_x);
            console.logBytes32(keys[i].pk_y);
        }
    }
}
