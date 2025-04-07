// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../src/PublicKeyRegistry.sol";
import "../src/Client1Verifier.sol";
import "../src/Client2Verifier.sol";
import "../src/Client3Verifier.sol";

// TODO: remove hardcoded proofs
// TODO: add more test cases
contract PublicKeyRegistryTest is Test {
    PublicKeyRegistry registry;
    Client1Verifier v1;
    Client2Verifier v2;
    Client3Verifier v3;

    address client1 = address(0x1);
    address client2 = address(0x2);
    address client3 = address(0x3);

    function setUp() public {
        registry = new PublicKeyRegistry();
        v1 = new Client1Verifier();
        v2 = new Client2Verifier();
        v3 = new Client3Verifier();
    }

    function testClientsRegisterWithProofs() public {
        // === Mock public keys and proofs ===
        bytes32 pk1_x = 0x0bb77a6ad63e739b4eacb2e09d6277c12ab8d8010534e0b62893f3f6bb957051;
        bytes32 pk1_y = 0x25797203f7a0b24925572e1cd16bf9edfce0051fb9e133774b3c257a872d7d8b;
        bytes32 pk2_x = 0x162d7e417903fa1c82f2d227e35b846b1133cfca4f558b5feb9fdcd5f81dd902;
        bytes32 pk2_y = 0x01666cafbf0a30da8b9ebeaf848a1da067a892296f1043188e1705402b6d6853;
        bytes32 pk3_x = 0x061c1436d1c3008037e887c8234dcf7c33c947ad93695b8000fcb4ab70477e3e;
        bytes32 pk3_y = 0x21d66f0e2295ae954494f25889f9319cc1b4df71eff3f46ba9e4631b43fd7c95;

        bytes memory proofForClient1 = hex"2b283e9d890793ebc03635ef1a2ac524040049887a06894be4343b5f921db6af0087c91ca6efbf5c0e0d69ea1d08534a6fab831dfd37922191cf03eed77cf87b1679c56d384bb0ff41c9aa680062cee3ab1b6dc74327960f2502bd1f9846f2a907060bedbc719968c791d9b97fd51dd518d8a4ad01b7864d9ae583e57b2b507d00a94d5e6eba2d05eeaede76294e4aaa623f62be259f8369ceff1337ebbd64431d8b0579c39d07070b568f7709849e22874260071678bff45dc9b8a8f17529c5256b08a92588027641aae57c1fd3b057f7d67cb628a5cd01bdc0280eaa5ca4902dcc4a73f338d9c9913b124952fa6989723417f8bab73332fe1db8a03949f6651ea4fc721578d979ecf4415def7a590d81cd9a3a7a982ed1dca25487b91c6dda179a6ff8fb634836da210f5ef2c8b4a3678c3a6c3dae842457682619b3e3ecaa1444ca34a411cb0f63d5866789763ae1e25ae49019e7e89a68b7fddc3922a7b00e6dae2c2c35884d2aca6febaed1bab52f1da64c2f3d01acea36462367be0ca50931533adb65b4d7e16d6e9c9345ca352d69d767fc9512bd335c7a2e9eae7a79230c067464290ba1b79aa5a76d03823000c1db32e70b933fcbb5b293b5ab39d4277668aae28c1fab44e9174f62ed8f3ffcae349bbbd42ef67b3fa37dd0788ad0241fc349ade3a62ebf0acfda5c086b6f01b14dd66b1b4cd3d8edbe61453df3f91cd2df6ebd12d137ac8237a72084005d7696ea2dab145924547bfdb6fc7f191d2ab22a27edae1549e162b82e05e6692650e875093b2bea557271117876c96d382abb70d5641344bd6d779b35eee66cef7130d05b771e678081dec2261a7eb9a3222ced67d8813e73e66fe0679814e693c429bcd1a9291afa75eb9507b868d2a90de63e7d8db0cb523c2d82aac39b533b60bb572c0e4f05c755e29a39c5bb43fc0893ae712bda5c252198dfa9b4dba4441ea59fe36050220f346c5f437d79a8ac2ea40d610420fda6faf1deadd328784b2f2bf0b9c1a9e350fde203a7bb0e094b17a03e4308acd0f1b1bd9cd79566479bf9302b559b78282b6d7b792bfb98af5624257757b98e4e241cca9ec1a3db74efeac884776a55f8a9ca1aca1286475690004f4f4cbcce106e7d097bdbfadcb3c2b60153d635a76703c41232219c94b73416c482a8a1f7d771bd1ea9a7ea6e92a5e643cefb686132b6742d11a7140596af0059472958b86a9fdcb652fc6ecde47123242d214888a1711f1b2da73ac6665b28abf466c8e74eea86d31d84f2040f12e039385f1e88093b7c75744e40bbb7c00aabd922c0d696db5118a54d8fb0f3419b7a91e20e051a193880060dba77b66824484c632f19faef01cbb6a816070ddb7ffe9ba5620ef9ddebbccbe14b99f9552160b3a155ccfa6ca2e00545f0fb66d492592ff55663ff9dd306a0cdd5ba15dc2ebdcb3f1ea35e575fdb64673095f23b74a1c56e94aa065046b38a090f0b9bcc2bcd68335ead4d800aafb9c3b2a246788106a4da0b9089de724d69fac80835810c54eaf3349a285ebacf954b39d56c7b79c65f54c9ac7d9e8dd72396debc206618fdf09cc992f80ac2a5146c2f624c7e0fd914a441909720be8e965898948a77160849cd9512a7e80bb65336f9525cb45aa84a752c801ce9390215d16eab5fbe156a02affcef990446797e9f0f7faeedaef0ab4af48627e59d66cc938ef3126c17cb1f6e357bff5a156a8cb0bbe33424897d301a6506d6ff20ab1c322d0e14782c1b2e4c53f87981e51640007adb12a060128009aa4afa3a11407595a05728c801fdb36ce8cbdddbdc5acae5667a41893fa4c87b79d37608f6b0473f13eb6a8c1a89b5d1e651cf449b9d9e2ace03681eda49c4962ea0f502c3749d3b71909b1a0db0b1fab83545288e8de4f4ac20880ddd906d88fba5754b9006b2adbddacd341c8d58eaa694cc05b34ca8d414aa3e923e9639b9460835322733bb6f694418901eee75a8df21325b823db6e5c10dc3c91922be88b688e44baa780b0e075f1a9c214f926717ad98b1512ec4f76d7148fff3af4358270993652dbc5aaca57a1ca823b0af255039ff07201fd30919d4ce36ce3bc827978a427eb100aa4b43951eb41a2c3c2c6e0865afe45b9ac26846b95b6409b4e9d5878618a3ef6bd0cb291684210a82a157dfabbf8625752bdbe69896430b86f266dfdc2a2915799cd0c04bff2bc5466c4245a40c7bd2d73262ee6a612ac05221867e9078770cd8443591fd3020bb6f84be7482297fc5c15096bc9324edd77d0f80cedd6825a8e778d0f0bfa119e05a0099f3648018e4e552626aad875e20579a38de2d732110f4aa0ccca45409ffe117a6160b1d307aeac8c52835773e68bf48973671d695222446bd9c6a4a082bcf814e4d34b882929f76713c328ba457fc8d6b7e7914b192009d68313fe001c52131e5bcd75e3b7f81a27b129638653bb58bee81b9bf86d3aaeee2d208af19998422bee669f06aaa5394aa6185ab247105c6ec5deb0746324ffa8c48197f0f1930815b2cb46a636fbc747f82fbda216bfa6963fd6441f3a00a37598d47152a6f4bbbc6eef35b2d328e76d923d6d2be1883ed848922258fa2760b6ce000ef043c7355ca607090635ee8d8e3b14ee2609c9d3240980070b65b9fd46969a63c2d6d89d34ee1da23cb5921f4dedba9bcc5f43efd6c000ccbed11009a81760da810f3cbada9fe418af6c060fa45c267a3bba5feb78e846d7c13911cef6c3fe42024de5bfae64c491bda77e5b62e2a7de7d98ba6ba2ac23ebd7df32ed84709ba9908649dd54168b08305df24bb95113bcecf3d66744d469f6da4734b2d31d3911112d20984b42e5ac61b0b0296ba01640b2e825c47ce2dd49583d0a900b453113212d8c58ed943c62ab2e24bae0149c55065ee3407f72cab77afbe43d919a544e91de56286119e806c39289bc6808c657e5630848075871e9320b6952f1595ab221f262b1511b41d6dbc6c0cf325f5616820e313a6597788a34e40b5359f4bced0";

        bytes memory proofForClient2 = hex"2155aeb05d8a52cb0f3c9c3622c49e556a50d0cec338967a2dc79794bbff59b20188f59c51f0ddfae2608c6d6499f5b6f6330433fcef22d7d754db6a2ff3bd142717f7ca0925b56d23d55bed83939f79ef4c20842efae0c38b26009bcb37570f0bcd64ae48d6ab7378c1da57bda3c9e21976805f551e52018654bb9cb7010de919c64ce0618e59f0f2b78e54c482a277de6b81202f81d1090f49dcbfec84e5de2a1f0febf30a6df970231bcc1ac6fafee0c3fa864399a98f01b94db61f207cd516ef47bb4dda4e4fc79767a16215e75d1320902d36351ab8a097b6e359b121e9300e35163106ca56a9f4b7303eeb23647582cf480576b64a060ac14128fb4adb095292be8ec0a4246579e0440b6ae7223c2e3f4a578df8343511175928d461c221bd0bfbefdf42fbf3107f7e04318c07e1883337026b64bc1d12b665277586221ef4a5019dd2815c54b786d48d66ac37cfda6a59b000bf9afc2c0195984a4c6e1e49131d8747ffaae906b89783f3f5b3c4d19c0fba809db13a02cbfe4823c99829d674967ad2ca2a9dc84dab2e6fceee6b1e847cb924c7fbef9207480470928c2dbfa6bdd999f1371c238dc75396c52382461254b4f6c36262100120e6d749c72a861927ecd3e81f6c5c92288c772b4e15aa0fd6e5cccd900ebdbda17ac609b0068abc19de478f58b207306fc2e46cb2863de55494516c455f0734f0b339c2081f4c8e5c77a930ff99f622fc2a4e54c9f9251961ed13a78841bd5f589606881919b09acbfb6590e2bb72b8497ac6e8ea8a897a41bddb60046edd9db3e594c15c0ccde2cc4893b6284eddd30003a4ebbd18ed4cb69092f3033e0ed0445b79c58324c2535e5ec74058b9adbbeb34d42a5660067037f10864ad60f945547a658d1e22f0eab9ba536ecfe5cc8858fde151c2a4d11db6a38e9728cdbb6052680936d621784b985f335568663aa40193b5b77c699828b8df847ed5ab9ecb0405c5b7d61065e78cace081c6d5c15047e7cce3b9d4f05a6a6bbc6e2e4a8cad733283f75229f632cad253a05acdf008ed14fde6683abaa9138761adfa9cb8c2137f470b012eb31e871e2864992902ea6ffd6bff05fcee0917c1edb34c853c9789e3d57d8316ee2c9820788f9d4cbf24241a8e6af1f13f9ad213681645facd03c26e21173709ee6fda03b02b8365ef7526121258969e480d83af10f58ad984550abb90dcbc062675462580414d58ca95fed1d0ee667f92b2e6a4e494fec63227ff4066ca50241cf8d5bb74f428118b9fbc685d9bc00b45e83748271466f72e7a70e74e7aec262daf84b8a2b94335238f186241e5cf23a927069264b916e8c6c511afab0f350684496c2e026caf06dcbdc9f29a0c8f62ce47981eaeece895d2ec2b8e0e7c061cb6c9148646ca3d125e9f4296a6a2aef30769be16dbaa35230a2ca07765bf9f0b838d97bffc9a7e1fa7d22aa779b61c211eb07a4681093e759aded376f203e7244561a9d78ef13519da822896732e36f7ec3b108493a4bf77deb69fddd49cc6103ab9bccb9565690595aaa0b1dde172a3a676f25c8bd59789fc15538eb4e64020b250c2208d64e7ee2854451e8df5d4fa9f22974d843d7e0dc90276a2d9bf6710d800b4bd4d3c3a5935593d15a18234e55b40f04fe5d456e30693b66ad950be2ab57162ffdf1e0a66be1d0e0a2c52314750687d4b920b786deaa158e78e4fa419f25b1e7f53a14e592156a20aa26cf0e80962321dde139a94d929af4148ca441752fad986bfcca2771545e610617410a7c3bd10b9eeedeeed481c8e0e4a6892216cd27a5381f75a65b2560060e82e75d3809263188b77b16a87c2b410d96186266e38360fe0834d543a86d69ea1e914daa593a43e6d4414bd7300119589577904f168aa623845105fd109cba8d87a39cae62f7ca5ac487a1cd6e81d6cfd927a28d07d085f6e47fff6380f808d0ffacd51af3de43c2f947026982fefe4bdbf85180d66c3dee2cb43e89b49148d86158cf26837990e7b9c924d86b8463e783a25074a507f5e574e87dafe82a88dfc304c9321314de0c7a4b47475409c9832b4c526eb88adbefd71f585b201f30ff3a3695c0e134b2ccd1d67df45be86e1ed2f66092f44d9fec824924b8490360b1887b088c25be6f02a1bbcbbc7b2059b0344e41a7b39774c0abeb2663de3b8516e44943d872eb027e750b7bb07f54c7c1a9677071701b6ce6638d7f60e3276f4b4b3d332a345de7649dcbe555cddb127f5ef6a034fe7a2af04860929348e953e052ed08a98e192fead971677739560e5c184362e2b2e3ce1535a4fe9bbb00189b5c73e7525122e20bf6d3f413e2bbb2690ccb929d535d65ba6bbe34227aa60be62b655528e7ea1d62be506e3899da68ad79f9313e98d0a7605d3602cc91ddea0f284017085bc8bde4bef7ef488cde93ed5af9418845068d66765e18da0858204def19f7a4a22b3017c6c96a502087e1e5b2f9424aa47f5f85c6d09991c6c3d3633b30ed3e4305cc3926d99c4cd776ae2b7eeaa1f2ca42a237ec1a0ed9cc767387c38daa0d3460fd6e22ff676bb60c0ace03c6e24c15af545158159013e329c15fa8aac5a7d39b9da3def7cce10729e8fd404792a3ac0bc24889e2b68fa20d28596005782c468a72ff1f10697a9148952a1880900c726b7681f62248efb40903c15eb2790a9fcccd3f1485fa6936a59cbbe3a8b2522fa1cd9b1e2718fcc64e52238c10610346abeeb907829e75e80bae60e14c2191a7f0f6a12c294d84d438386da3e87678af06889763762e447a188105deef80d120401fa73a2b820ce2221eb7bbc08bee17612275bf69be130c2553aadc92e29a29b5f8e2c27d1af5aeff7b634b0b3a4d94a37139db2303c0bb69780295f8f20619dac9411a87c955c042f6110aa742995a4a1d84b13edba674017363a18bd26f96a132c5e4167301e564273ad2b62c8d7625060341e9cf6f99f0520736ef808b72c3105e6263b6b012fc7bc125285190c6d82eb7f1f3f016d2f602dac3529";

        bytes memory proofForClient3 = hex"00b7798a783b3834653ed95ce1477296423591e4d35f38d075ed3576edf74b41301a5dedf06a388bc7831e61b27ac319faa11f49e29a810e1d4f4c24f055b6ba13e39a8489daf5e288b60a469569eb4c8bfa58c16ab284fe3de396becd2d3f3226409143064a51691ece60fe74fbf38e363a9b2ed64b45b012ca23b1024a549f0233a7f188f1466ab7628b1a29eebc3907b27918c941e09e3c9f7b5bdc7737d328371320347acb0e30e17645f73df900797e2d7b544cc72a4b4827a2321fb4f32ea48d071f5f972c8a5c27ecec4798e5c3d38ffab1cf2dfedb93c5d845baa5bf202b5e3d6730a96a1ab12fd847cd05a345bea25d7b88f2bcef673a8a2d048c4d2ff9b4e8f1e6067c9768dd3a5e16ffdb330ba26c9fad069f4b79ab1bdd9169c209223f37246d3ae349ffaaa7a014784e2f7a8f7f84b82981e173769daef36ec80c1ddd29b408f6cee065c4962dd13d8240b8b7a4c7c0265705415d2d808a63f82fe4815e37feaeeeae09c2c7a7a801909d25c6527d16d48de629a5b82341724002b63b89829b80e01717f99c1723267861b42c67de6ac4b5dd6b0f1cb564b67c1c59df0c7498b2730d7ed1114f367456282317473738652b40058620065784ea28982b03b06003d0f681b063fa70b132010725fd7ab02fcce4210cbbd67ca6530655f67ba78c176f75c5defa324a069910e5442aa4a2755ecc93dbad21f9e213208203dbfea61fc3ffe058cba4264d9a19362e6fc05988033f7a855e1a932b8828fc49c03fddb97e2d8e865008239381b1b76f575dd2957b617d9c2748d249b011ed16dfc350251053ae3d8fd44dbfee05e74c7fb577a455e6ae7580d185551e2377f17b1d8221460afaaca9c789b1494a48bc40cc6d139edceb7e45608cb5fc056311153422adcda83f407f9d32ecbd2978e3d2ad4eb008a7139936a35e07c0147df5072ba42ca8ed614d7ad21713f0d944f7af1073732a6915603b19b58bb311a95bd96b91dc219799156263959163ded1ffbedc29e87065f0cca04f4675bc07e92a82adbb8bbf90d4d2d9670170f620c732487b2ee67ff3b4e2c5e36d3824207f7f3897e1e18ceaf669dfa9a6b538ee0f1e78a53696450a613cb8fd7e33c21ffdb371a892e4bd9820d31daf6852c5f57772d781eddfd28d6b281aabd213a00e79965f8edd5b90c89f03531216fc88602fb4076ea40ba82fe64fd3a56e6a1d1fdacaa6a3d8e752d940983b9a8e6f41e7abc56be809c1b61ecac525c9a3f62c1dc7d9639f4d621413234ebf6125c40bb43259bfdc02879bdd72706e100e603420faeb3a16dfb6003b36193821ce06a02c368a0b79e7d15a617f143ad3790beb1781fd64e26901e558d6fcfa0b71a27c599ee042467e136e8c4255e48f66c0f21c5d5f6b06e1869cb029d916f8dfce581f4f7d5871d1b2a4dd7e76f53d6e5ec813c8e51c78b8a7aa83f93a33f09625e5c0101cff61e0039e3451f1f3bba081b40d2438a9255aa4f4daaf2d96bbc47a4377166da7a0da8ea5963a52a77fcfd30d2d17b734a21d6183df46efb4fbdbab29a16365df9ea7a42f66a6a994f36037b025bb9ef0f276f65bb0e2fb1ab6c6ccd763c439f4615f1644f11c579a247222c419200ba6e3e515356b30da0a4206fc698b114e85f7556c2bf2937f01fab4843f0c14ca15d6f2ddbb41fee2b03c78cc52cd6f5ae5328fb146df8789775552bf85080bf44464085659a6a0825a34cd2e8a8a75f5da2aa77f93f0d2d2c97d069be9150bb59e9e91ce5b1a9ad7f1a481b27ead60c322cc3a6218b379dc9c2a20a3670af92ed9d193c9b8fe286a74ac366a2aea364ea5d4efd4f75f80f222602aaf2a2bfffe0ade2c5cac6cbe06793a45d877ca6634b0aa1f39530dd9083e78eba4e91c63d0b4bc8492ebbc779aff425ed528624c35aa453fc67290d4b87244e5a010305e97145f64e7c028340764a6f74b572cb7140c94908cbf574b5b01bc6e54b22c55c142ec7a605e8cd5a70e9f4bad8ee9bdaf018ca85b0c6896a453e4223116284ceb71798fd8fcf17746b897a00fc6a6c449f684c0295979e1eda60bd60d7a244415a006a5519b5618e6628ff471fe63cae4eb7cd7f7a68b2d36f83389e9de04031e72f11dcef80b4222042d2190c2477c90cf22bf4de1021e1c1ba4ba784d04eb2e0cba756fe8dee0123a85376d685c6ad182be6e81b2c044c866e14d940d1ecb57167dbe1dd408f4c76daba1522506779823fdcd5e8171916dae75b82a6b10b349f213c68160edd7886d3f808af9c0f6b84c5478dea30e1612b3ba59582e0c5b300e831d85139c2ec132e06098103ddd2c353e881692245b861d4e767ef2150548db5949c5c2ef0491c911346965637b7ae4fd71f0b736259ad6b981edcc266317c4c68acc984dfdbfedcd5b8c27b2a9a2f5f26ae1db476a7e1b1b87d5921d6c9ef61eacf4550187b0c1d7983e92df76fb33635eaad8d82a961c6e460f67191857c7ea29f5de696677bda3f2858972bf04ef74f1da32d08144838cb8ff502948221cb026570cf4f3f08dcb7b4ac2af4fad7651d2866410d5cb78ece574301c0623457a3bed152def7fe8d69ee6fbc593f2d27887e0761b8ee4e4674c95fe098f5ef6fd5ec277c568ddbca477001bef788d6d2250a09eaba5455c904530e2027f89efbfa0faa13e614a76d02d3c35595c15c549ee45724043e49d088c31610ecde90b1d3acce3c6fd776e573c01fbc030bc5283db276016975fb9c5428ad41b1c48267ad49f264f99a465de4ac7c2270562dfbdc8094deceadad681f8e447276aa741d86e7168d835d15d65598d888dda096cf7b4eb3bc33e55f33eaf3dba090d81b841862773632310f9561bf31eb5a9cb1250681bcedc2fc8d3c059bcfa1a75b11dceb09a63781617392980dc654afb07ec7744f1188cb3dc89bd12594a2cd69726d0447ad0ff9e3499bbfe77e6ac29c4f22bc3d3e367297cbde029271d1fe13711b9be26030a0492afd1c768cedab1765c30eb8ce88ddc5f2fcf52a00b";
        bytes32[] memory dummyInputs; // should be empty in the correct case

        // === Register public keys ===
        vm.prank(client1);
        registry.registerPublicKey(proofForClient1, address(v1), pk1_x, pk1_y, dummyInputs);

        vm.prank(client2);
        registry.registerPublicKey(proofForClient2, address(v2), pk2_x, pk2_y, dummyInputs);

        vm.prank(client3);
        registry.registerPublicKey(proofForClient3, address(v3), pk3_x, pk3_y, dummyInputs);

        vm.prank(client1);
        (PublicKeyRegistry.PublicKey memory cl1_lower, PublicKeyRegistry.PublicKey memory cl1_higher) = registry.getNeighborPublicKeys();

        console.log("Client1's lower neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl1_lower.pk_x);
        console.logBytes32(cl1_lower.pk_y);

        console.log("Client1's higher neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl1_higher.pk_x);
        console.logBytes32(cl1_higher.pk_y);

        vm.prank(client2);
        (PublicKeyRegistry.PublicKey memory cl2_lower, PublicKeyRegistry.PublicKey memory cl2_higher) = registry.getNeighborPublicKeys();

        console.log("Client2's lower neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl2_lower.pk_x);
        console.logBytes32(cl2_lower.pk_y);

        console.log("Client2's higher neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl2_higher.pk_x);
        console.logBytes32(cl2_higher.pk_y);

        vm.prank(client3);
        (PublicKeyRegistry.PublicKey memory cl3_lower, PublicKeyRegistry.PublicKey memory cl3_higher) = registry.getNeighborPublicKeys();

        console.log("Client3's lower neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl3_lower.pk_x);
        console.logBytes32(cl3_lower.pk_y);

        console.log("Client3's higher neighbor's ECDH public key (pk_x, pk_y):");
        console.logBytes32(cl3_higher.pk_x);
        console.logBytes32(cl3_higher.pk_y);
    }
}