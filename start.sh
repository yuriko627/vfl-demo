#!/bin/bash

SESSION="vfl_cli_demo"

# Clean up any previous marker files
rm -f /tmp/.train_done0 /tmp/.train_done1 /tmp/.train_done2 /tmp/.deploy_done

tmux new-session -d -s $SESSION -c ./clients/client1

# Split the window horizontally
tmux split-window -h -t $SESSION -c ./server
tmux select-layout -t $SESSION even-horizontal

# Vertically split the left half window into 3 panes
tmux split-window -v -t $SESSION:0.0 -c ./clients/client3
tmux split-window -v -t $SESSION:0.0 -c ./clients/client2

# Vertically split the right half window into 2 panes
tmux split-window -v -t $SESSION:0.3 -c ./

# Resize pane 0-2 to have the same height
HEIGHT0=$(tmux display-message -p -t 0 '#{pane_height}')
HEIGHT1=$(tmux display-message -p -t 1 '#{pane_height}')
HEIGHT2=$(tmux display-message -p -t 2 '#{pane_height}')
TOTAL=$((HEIGHT0 + HEIGHT1 + HEIGHT2))
EVENHEIGHT=$((TOTAL / 3))
tmux resize-pane -t 0 -y $EVENHEIGHT
tmux resize-pane -t 1 -y $EVENHEIGHT

# Run training script in each client and create `done` marker files
tmux send-keys -t 0 'clear; cd ./client1_training; fish client1_train.fish; touch /tmp/.train_done0' C-m
tmux send-keys -t 1 'clear; cd ./client2_training; fish client2_train.fish; touch /tmp/.train_done1' C-m
tmux send-keys -t 2 'clear; cd ./client3_training; fish client3_train.fish; touch /tmp/.train_done2' C-m

# In pane 3 (server), wait for all clients to complete the training, then deploy contract
tmux send-keys -t 3 'clear; bash -c "
echo Simulating a server
while [ ! -f /tmp/.train_done0 ] || [ ! -f /tmp/.train_done1 ] || [ ! -f /tmp/.train_done2 ]; do
  echo Waiting...
  sleep 1
done
fish server.fish | tee /tmp/server_output.log; touch /tmp/.deploy_done

# Extract contract address
grep 'Client1Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1verifier_address
grep 'Client2Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2verifier_address
grep 'Client3Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3verifier_address
grep 'PublicKeyRegistry' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/pkregistry_address
"' C-m

# In pane 4, start anvil nodes
tmux send-keys -t 4 'clear; anvil' C-m


# Once Pane 3 is done, restart client0-2 for sending a transaction for public key register
# contract address captured in pane 3
tmux send-keys -t 0 'bash -c "
while [ ! -f /tmp/.deploy_done ]; do
  echo [client1] Waiting for /tmp/.deploy_done...
  sleep 1
done
echo Contract deployed
cd ../client1_masking
fish client1_mask.fish
"' C-m

tmux send-keys -t 1 'bash -c "
while [ ! -f /tmp/.deploy_done ]; do
  echo [client2] Waiting for /tmp/.deploy_done...
  sleep 1
done
echo Contract deployed
cd ../client2_masking
fish client2_mask.fish
"' C-m

tmux send-keys -t 2 'bash -c "
while [ ! -f /tmp/.deploy_done ]; do
  echo [client3] Waiting for /tmp/.deploy_done...
  sleep 1
done
echo Contract deployed
cd ../client3_masking
fish client3_mask.fish
"' C-m

# Attach to session
tmux attach -t $SESSION