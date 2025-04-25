#!/usr/bin/env bash

set -e
trap 'echo "❌ Error on line $LINENO. Exiting."; exit 1' ERR

SESSION="vfl_cli_demo"

# Clean up any previous marker files
rm -f /tmp/.deploy_contracts_done /tmp/.publish_model_done* /tmp/.aggregate_done /tmp/.train*_done

# Clean up temporary values created in previous sessions
rm -f /tmp/anvil.log /tmp/client*maskverifier_address /tmp/client*trainverifier_address /tmp/deploy_model_output.log /tmp/deploy_pk_output.log /tmp/global_model /tmp/model*  /tmp/pk*_x /tmp/pk*_y /tmp/pkregistry_address /tmp/modelregistry_address tmp/serververifier_address

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

# Once contract deployment is done, start training + masking model on the client1-3
# Once the aggregation is done on the server side, fetch the global model
tmux send-keys -t 0 'clear; bash -c "
set -e
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client1] Waiting for all the contracts to be deployed...
  sleep 1
done

start=\$(date +%s)

bash ../../scripts/train.sh 1; touch /tmp/.train1_done
while [ ! -f /tmp/.train2_done ] || [ ! -f /tmp/.train3_done ]; do
  echo Waiting for other clinets to be done training...
  sleep 0.1
done
bash ../../scripts/mask.sh 1
bash ../../scripts/publish_model.sh 1
touch /tmp/.publish_model_done1

while [ ! -f /tmp/.aggregate_done ]; do
  echo [client1] Waiting for the server to aggregate local models...
  sleep 0.1
done

bash ../../scripts/fetch_global_model.sh 1

end=\$(date +%s)
elapsed=\$((end - start))
echo [client1] Total time from training to fetching global model: \$elapsed seconds
"' C-m


tmux send-keys -t 1 'clear; bash -c "
set -e
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client2] Waiting for all the contracts to be deployed...
  sleep 1
done

start=\$(date +%s)

bash ../../scripts/train.sh 2; touch /tmp/.train2_done
while [ ! -f /tmp/.train1_done ] || [ ! -f /tmp/.train3_done ]; do
  echo Waiting for other clinets to be done training...
  sleep 1
done
bash ../../scripts/mask.sh 2
bash ../../scripts/publish_model.sh 2
touch /tmp/.publish_model_done2

while [ ! -f /tmp/.aggregate_done ]; do
  echo [client1] Waiting for the server to aggregate local models...
  sleep 0.1
done

bash ../../scripts/fetch_global_model.sh 2

end=\$(date +%s)
elapsed=\$((end - start))
echo [client2] Total time from training to fetching global model: \$elapsed seconds
"' C-m

tmux send-keys -t 2 'clear; bash -c "
set -e
while [ ! -f /tmp/.deploy_contracts_done ]; do
  echo [client3] Waiting for all the contracts to be deployed...
  sleep 1
done

start=\$(date +%s)

bash ../../scripts/train.sh 3; touch /tmp/.train3_done
while [ ! -f /tmp/.train1_done ] || [ ! -f /tmp/.train2_done ]; do
  echo Waiting for other clinets to be done training...
  sleep 1
done
bash ../../scripts/mask.sh 3
bash ../../scripts/publish_model.sh 3
touch /tmp/.publish_model_done3

while [ ! -f /tmp/.aggregate_done ]; do
  echo [client3] Waiting for the server to aggregate local models...
  sleep 0.1
done

bash ../../scripts/fetch_global_model.sh 3

end=\$(date +%s)
elapsed=\$((end - start))
echo [client3] Total time from training to fetching global model: \$elapsed seconds
"' C-m

# In pane 3 (server)
# 1. Deploy PublicKeyRegistry and ModelRegistry contracts first
# 2. Wait for all clients to publish the masked models
# 3. Fetch all of them and aggregate
tmux send-keys -t 3 'clear; bash -c "

echo [Server]: Deploy necessary contracts first
bash ../scripts/deploy_pk_registry.sh | tee /tmp/deploy_pk_output.log;
bash ../scripts/deploy_model_registry.sh | tee /tmp/deploy_model_output.log; touch /tmp/.deploy_contracts_done;

echo Waiting for the clients to complete a local training and submit masked models
while [ ! -f /tmp/.publish_model_done1 ] || [ ! -f /tmp/.publish_model_done2 ] || [ ! -f /tmp/.publish_model_done3 ]; do
  echo Waiting...
  sleep 1
done
bash ../scripts/aggregate.sh; touch /tmp/.aggregate_done
"' C-m

# In pane 4, start Anvil node
tmux send-keys -t 4 'clear; anvil' C-m

# wait until the log is shown
while ! tmux capture-pane -pt 4 -S -1000 | grep -q "Available Accounts"; do
  sleep 0.5
done

# capture the full log from pane 4
tmux capture-pane -pt 4 -S -1000 > /tmp/anvil.log

# Attach to session
tmux attach -t $SESSION