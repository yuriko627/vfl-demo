#!/bin/bash

SESSION="vfl_cli_demo"

# Clean up any previous marker files
rm -f /tmp/.deploy_contracts_done /tmp/.publish_model_done1 /tmp/.publish_model_done2 /tmp/.publish_model_done3

tmux new-session -d -s $SESSION -c clients/client1

# Split the window horizontally
tmux split-window -h -t $SESSION -c server
tmux select-layout -t $SESSION even-horizontal

# Vertically split the left half window into 3 panes
tmux split-window -v -t $SESSION:0.0 -c clients/client3
tmux split-window -v -t $SESSION:0.0 -c clients/client2

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

# In pane 3 (server), deploy PublicKeyRegistry and ModelRegistry contracts first
tmux send-keys -t 3 'clear; bash -c "
echo [Server]: Deploy necessary contracts first
bash ../scripts/deploy_pk_registry.sh | tee /tmp/deploy_pk_output.log;
bash ../scripts/deploy_model_registry.sh | tee /tmp/deploy_model_output.log; touch /tmp/.deploy_contracts_done;
"' C-m

# In pane 4, start anvil nodes
tmux send-keys -t 4 'clear; anvil' C-m
sleep 3
tmux capture-pane -pt 4 -S -1000 > /tmp/anvil_log # capture the log after it outputs available accounts and private keys

# Once contract deployment is done, start training + masking model on the client1-3
tmux send-keys -t 0 'clear; bash -c "
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client1] Waiting for all the contracts to be deployed...
  sleep 1
done
bash ../../scripts/train.sh 1
bash ../../scripts/mask.sh 1
bash ../../scripts/publish_model.sh 1; touch /tmp/.publish_model_done1
"' C-m

tmux send-keys -t 1 'clear; bash -c "
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client2] Waiting for all the contracts to be deployed...
  sleep 1
done
bash ../../scripts/train.sh 2
bash ../../scripts/mask.sh 2
bash ../../scripts/publish_model.sh 2; touch /tmp/.publish_model_done2;
"' C-m

tmux send-keys -t 2 'clear; bash -c "
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client3] Waiting for all the contracts to be deployed...
  sleep 1
done
bash ../../scripts/train.sh 3
bash ../../scripts/mask.sh 3
bash ../../scripts/publish_model.sh 3; touch /tmp/.publish_model_done3
"' C-m


# In pane 3 (server), wait for all clients to publish the masked models, then fetch them
tmux send-keys -t 3 'clear; bash -c "
echo Waiting for the clients to complete a local training and submit masked models
while [ ! -f /tmp/.publish_model_done1 ] || [ ! -f /tmp/.publish_model_done2 ] || [ ! -f /tmp/.publish_model_done3 ]; do
  echo Waiting...
  sleep 1
done
bash ../scripts/aggregate.sh
"' C-m

# Attach to session
tmux attach -t $SESSION