#!/usr/bin/env fish

osascript -e '
tell application "iTerm"
    activate
    create window with default profile

    tell current window
        -- Pane 1: client1
        tell current session
            write text "cd ~/Development/vfl-demo/clients/client1/client1_training && echo \"Start training a model on client1\" && nargo execute && bb prove -b ./target/client1_training.json -w ./target/client1_training.gz -o ./target/proof && bb write_vk -b ./target/client1_training.json -o ./target/vk && bb contract && echo \"Client 1: training done, verifier contract is ready to deploy\" && cp ./target/contract.sol ../../../contracts/pkregistry/src/Client1Verifier.sol"
            split vertically with default profile
        end tell

        -- Pane 2: client2
        tell session 2 of current tab
            write text "cd ~/Development/vfl-demo/clients/client2/client2_training && echo \"Start training a model on client2\" && nargo execute && bb prove -b ./target/client2_training.json -w ./target/client2_training.gz -o ./target/proof && bb write_vk -b ./target/client2_training.json -o ./target/vk && bb contract && echo \"Client 2: training done, verifier contract is ready to deploy\" && cp ./target/contract.sol ../../../contracts/pkregistry/src/Client2Verifier.sol "
            split vertically with default profile
        end tell

        -- Pane 3: client3
        tell session 3 of current tab
            write text "cd ~/Development/vfl-demo/clients/client3/client3_training && echo \"Start training a model on client3\" && nargo execute && bb prove -b ./target/client3_training.json -w ./target/client3_training.gz -o ./target/proof && bb write_vk -b ./target/client3_training.json -o ./target/vk && bb contract && echo \"Client 3: training done, verifier contract is ready to deploy\" && cp ./target/contract.sol ../../../contracts/pkregistry/src/Client3Verifier.sol "
        end tell
    end tell
end tell'

# echo " Deploy PublickeyRegistry contract and 3 verifier contracts"

# echo " Deployed contract address:"

# echo " Registering mock private/public keys to 3 clients to interact with the contract"

# echo " Submitting transaction to anvil smart contract"

# echo " Training Proof from client 1 verified! Submitted ECDH public key: "

# echo " Training Proof from client 2 verified! Submitted ECDH public key: "

# echo " Training Proof from client 3 verified! Submitted ECDH public key: "
