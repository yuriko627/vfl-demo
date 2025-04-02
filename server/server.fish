echo " Deploy 3 verifier contracts and PublickeyRegistry contract"

cd ../contracts/pkregistry/

forge script script/DeployPublicKeyRegistry.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80