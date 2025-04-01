#!/usr/bin/env fish

echo "😶‍🌫️ Start masking a model on Client2"

# Send transaction to verify the proof of correct training,
# and if this verification passes, register ECDH public key on chain
echo "Verify proof and register ECDH public key on chain"
cast send 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318 \
  "registerPublicKey(bytes,address,bytes32,bytes32,bytes32[])" \
  0x2155aeb05d8a52cb0f3c9c3622c49e556a50d0cec338967a2dc79794bbff59b20188f59c51f0ddfae2608c6d6499f5b6f6330433fcef22d7d754db6a2ff3bd142717f7ca0925b56d23d55bed83939f79ef4c20842efae0c38b26009bcb37570f0bcd64ae48d6ab7378c1da57bda3c9e21976805f551e52018654bb9cb7010de919c64ce0618e59f0f2b78e54c482a277de6b81202f81d1090f49dcbfec84e5de2a1f0febf30a6df970231bcc1ac6fafee0c3fa864399a98f01b94db61f207cd516ef47bb4dda4e4fc79767a16215e75d1320902d36351ab8a097b6e359b121e9300e35163106ca56a9f4b7303eeb23647582cf480576b64a060ac14128fb4adb095292be8ec0a4246579e0440b6ae7223c2e3f4a578df8343511175928d461c221bd0bfbefdf42fbf3107f7e04318c07e1883337026b64bc1d12b665277586221ef4a5019dd2815c54b786d48d66ac37cfda6a59b000bf9afc2c0195984a4c6e1e49131d8747ffaae906b89783f3f5b3c4d19c0fba809db13a02cbfe4823c99829d674967ad2ca2a9dc84dab2e6fceee6b1e847cb924c7fbef9207480470928c2dbfa6bdd999f1371c238dc75396c52382461254b4f6c36262100120e6d749c72a861927ecd3e81f6c5c92288c772b4e15aa0fd6e5cccd900ebdbda17ac609b0068abc19de478f58b207306fc2e46cb2863de55494516c455f0734f0b339c2081f4c8e5c77a930ff99f622fc2a4e54c9f9251961ed13a78841bd5f589606881919b09acbfb6590e2bb72b8497ac6e8ea8a897a41bddb60046edd9db3e594c15c0ccde2cc4893b6284eddd30003a4ebbd18ed4cb69092f3033e0ed0445b79c58324c2535e5ec74058b9adbbeb34d42a5660067037f10864ad60f945547a658d1e22f0eab9ba536ecfe5cc8858fde151c2a4d11db6a38e9728cdbb6052680936d621784b985f335568663aa40193b5b77c699828b8df847ed5ab9ecb0405c5b7d61065e78cace081c6d5c15047e7cce3b9d4f05a6a6bbc6e2e4a8cad733283f75229f632cad253a05acdf008ed14fde6683abaa9138761adfa9cb8c2137f470b012eb31e871e2864992902ea6ffd6bff05fcee0917c1edb34c853c9789e3d57d8316ee2c9820788f9d4cbf24241a8e6af1f13f9ad213681645facd03c26e21173709ee6fda03b02b8365ef7526121258969e480d83af10f58ad984550abb90dcbc062675462580414d58ca95fed1d0ee667f92b2e6a4e494fec63227ff4066ca50241cf8d5bb74f428118b9fbc685d9bc00b45e83748271466f72e7a70e74e7aec262daf84b8a2b94335238f186241e5cf23a927069264b916e8c6c511afab0f350684496c2e026caf06dcbdc9f29a0c8f62ce47981eaeece895d2ec2b8e0e7c061cb6c9148646ca3d125e9f4296a6a2aef30769be16dbaa35230a2ca07765bf9f0b838d97bffc9a7e1fa7d22aa779b61c211eb07a4681093e759aded376f203e7244561a9d78ef13519da822896732e36f7ec3b108493a4bf77deb69fddd49cc6103ab9bccb9565690595aaa0b1dde172a3a676f25c8bd59789fc15538eb4e64020b250c2208d64e7ee2854451e8df5d4fa9f22974d843d7e0dc90276a2d9bf6710d800b4bd4d3c3a5935593d15a18234e55b40f04fe5d456e30693b66ad950be2ab57162ffdf1e0a66be1d0e0a2c52314750687d4b920b786deaa158e78e4fa419f25b1e7f53a14e592156a20aa26cf0e80962321dde139a94d929af4148ca441752fad986bfcca2771545e610617410a7c3bd10b9eeedeeed481c8e0e4a6892216cd27a5381f75a65b2560060e82e75d3809263188b77b16a87c2b410d96186266e38360fe0834d543a86d69ea1e914daa593a43e6d4414bd7300119589577904f168aa623845105fd109cba8d87a39cae62f7ca5ac487a1cd6e81d6cfd927a28d07d085f6e47fff6380f808d0ffacd51af3de43c2f947026982fefe4bdbf85180d66c3dee2cb43e89b49148d86158cf26837990e7b9c924d86b8463e783a25074a507f5e574e87dafe82a88dfc304c9321314de0c7a4b47475409c9832b4c526eb88adbefd71f585b201f30ff3a3695c0e134b2ccd1d67df45be86e1ed2f66092f44d9fec824924b8490360b1887b088c25be6f02a1bbcbbc7b2059b0344e41a7b39774c0abeb2663de3b8516e44943d872eb027e750b7bb07f54c7c1a9677071701b6ce6638d7f60e3276f4b4b3d332a345de7649dcbe555cddb127f5ef6a034fe7a2af04860929348e953e052ed08a98e192fead971677739560e5c184362e2b2e3ce1535a4fe9bbb00189b5c73e7525122e20bf6d3f413e2bbb2690ccb929d535d65ba6bbe34227aa60be62b655528e7ea1d62be506e3899da68ad79f9313e98d0a7605d3602cc91ddea0f284017085bc8bde4bef7ef488cde93ed5af9418845068d66765e18da0858204def19f7a4a22b3017c6c96a502087e1e5b2f9424aa47f5f85c6d09991c6c3d3633b30ed3e4305cc3926d99c4cd776ae2b7eeaa1f2ca42a237ec1a0ed9cc767387c38daa0d3460fd6e22ff676bb60c0ace03c6e24c15af545158159013e329c15fa8aac5a7d39b9da3def7cce10729e8fd404792a3ac0bc24889e2b68fa20d28596005782c468a72ff1f10697a9148952a1880900c726b7681f62248efb40903c15eb2790a9fcccd3f1485fa6936a59cbbe3a8b2522fa1cd9b1e2718fcc64e52238c10610346abeeb907829e75e80bae60e14c2191a7f0f6a12c294d84d438386da3e87678af06889763762e447a188105deef80d120401fa73a2b820ce2221eb7bbc08bee17612275bf69be130c2553aadc92e29a29b5f8e2c27d1af5aeff7b634b0b3a4d94a37139db2303c0bb69780295f8f20619dac9411a87c955c042f6110aa742995a4a1d84b13edba674017363a18bd26f96a132c5e4167301e564273ad2b62c8d7625060341e9cf6f99f0520736ef808b72c3105e6263b6b012fc7bc125285190c6d82eb7f1f3f016d2f602dac3529 \
  0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 \
  0x162d7e417903fa1c82f2d227e35b846b1133cfca4f558b5feb9fdcd5f81dd902 \
  0x01666cafbf0a30da8b9ebeaf848a1da067a892296f1043188e1705402b6d6853 \
  [] \
  --rpc-url http://localhost:8545 \
  --private-key 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

# Fectch 2 neigbor clients' public keys
echo "🔑 Fectch 2 neigbor clients' public keys (lower node: Client1, higher node: Client3)"
set fetched_output (cast call 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318 \
  "getNeighborPublicKeys()" \
  --rpc-url http://localhost:8545 \
  --from 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f 2>&1)

# Extract the last 256 characters
set pk (string sub -s (math (string length $fetched_output) - 255) $fetched_output)

echo "✅ Fetched raw public key hex:"
echo $pk

# Parse $pk and write to Prover.toml
echo "🛠️ Parse public keys and save them in Prover.toml..."
fish ../../../parse_fetched_pk.fish \
  $pk \
  ./Prover.toml

nargo execute
bb prove -b ./target/client2_masking.json -w ./target/client2_masking.gz -o ./target/proof
bb write_vk -b ./target/client2_masking.json -o ./target/vk
bb contract