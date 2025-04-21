#!/bin/bash

SESSION="vfl_cli_demo"

# Clean up any previous marker files
rm -f /tmp/.train_done0 /tmp/.train_done1 /tmp/.train_done2 /tmp/.deploy_pk_done /tmp/.mask_done0 /tmp/.mask_done1 /tmp/.mask_done2 /tmp/.deploy_model_done /tmp/.publish_model_done0 /tmp/.publish_model_done1 /tmp/.publish_model_done2

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
tmux send-keys -t 0 'clear; cd ./training; bash ../../../scripts/train.sh 1; touch /tmp/.train_done0' C-m
tmux send-keys -t 1 'clear; cd ./training; bash ../../../scripts/train.sh 2; touch /tmp/.train_done1' C-m
tmux send-keys -t 2 'clear; cd ./training; bash ../../../scripts/train.sh 3; touch /tmp/.train_done2' C-m

# In pane 3 (server), wait for all clients to complete the training, then deploy contract
tmux send-keys -t 3 'clear; bash -c "
echo Simulating a server
while [ ! -f /tmp/.train_done0 ] || [ ! -f /tmp/.train_done1 ] || [ ! -f /tmp/.train_done2 ]; do
  echo Waiting...
  sleep 1
done
bash ../scripts/deploy_pk_registry.sh | tee /tmp/deploy_pk_output.log; touch /tmp/.deploy_pk_done
"' C-m

# In pane 4, start anvil nodes
tmux send-keys -t 4 'clear; anvil' C-m

# Once pk_registry contract deployment is done, restart client0-2, sending a transaction to register public key
# contract address captured in pane 3
tmux send-keys -t 0 'bash -c "
while [ ! -f /tmp/.deploy_pk_done ]; do
  echo [client1] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish client1_mask.fish
touch /tmp/.mask_done0
"' C-m

tmux send-keys -t 1 'bash -c "
while [ ! -f /tmp/.deploy_pk_done ]; do
  echo [client2] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish client2_mask.fish
touch /tmp/.mask_done1
"' C-m

tmux send-keys -t 2 'bash -c "
while [ ! -f /tmp/.deploy_pk_done ]; do
  echo [client3] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish client3_mask.fish
touch /tmp/.mask_done2
"' C-m

# In pane 3 (server), wait for all clients to complete masking the model, then deploy contract
tmux send-keys -t 3 'clear; bash -c "
echo Waiting for the clients to complete masking the model
while [ ! -f /tmp/.mask_done0 ] || [ ! -f /tmp/.mask_done1 ] || [ ! -f /tmp/.mask_done2 ]; do
  echo Waiting...
  sleep 1
done
bash ../scripts/deploy_model_registry.sh | tee /tmp/deploy_model_output.log; touch /tmp/.deploy_model_done
"' C-m

# Once model_registry contract deployment is done, restart client0-2, sending a transaction to register the masked model
# contract address captured in pane 3
tmux send-keys -t 0 'bash -c "
while [ ! -f /tmp/.deploy_model_done ]; do
  echo [client1] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish publish_model1.fish
touch /tmp/.publish_model_done0
"' C-m

tmux send-keys -t 1 'bash -c "
while [ ! -f /tmp/.deploy_model_done ]; do
  echo [client2] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish publish_model2.fish
touch /tmp/.publish_model_done1
"' C-m

tmux send-keys -t 2 'bash -c "
while [ ! -f /tmp/.deploy_model_done ]; do
  echo [client3] Waiting for the model_registry contract to be deployed...
  sleep 1
done
echo Contract deployed
cd ../masking
fish publish_model3.fish
touch /tmp/.publish_model_done2
"' C-m

# In pane 3 (server), wait for all clients to publish the masked models, then fetch them
tmux send-keys -t 3 'clear; bash -c "
echo Waiting for the clients to complete masking the model
while [ ! -f /tmp/.publish_model_done0 ] || [ ! -f /tmp/.publish_model_done1 ] || [ ! -f /tmp/.publish_model_done2 ]; do
  echo Waiting...
  sleep 1
done
fish ./aggregate.fish
"' C-m

# Attach to session
tmux attach -t $SESSION