#!/bin/bash

SESSION="vfl_cli_demo"

# Clean up any previous marker files
rm -f /tmp/.done0 /tmp/.done1 /tmp/.done2 /tmp/.server_done

tmux new-session -d -s $SESSION -c ./clients/client1/client1_training

# Split the window horizontally
tmux split-window -h -t $SESSION -c ./server
tmux select-layout -t $SESSION even-horizontal

# Vertically split the left half window into 3 panes
tmux split-window -v -t $SESSION:0.0 -c ./clients/client3/client3_training
tmux split-window -v -t $SESSION:0.0 -c ./clients/client2/client2_training

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

# Run script in each client and create marker files
tmux send-keys -t 0 'clear; fish client1_train.fish; touch /tmp/.done0' C-m
tmux send-keys -t 1 'clear; fish client2_train.fish; touch /tmp/.done1' C-m
tmux send-keys -t 2 'clear; fish client3_train.fish; touch /tmp/.done2' C-m

# In pane 3 (server), wait for all to complete, then run final program
tmux send-keys -t 3 'clear; bash -c "
echo Simulating a server
while [ ! -f /tmp/.done0 ] || [ ! -f /tmp/.done1 ] || [ ! -f /tmp/.done2 ]; do
  echo Waiting...
  sleep 1
done
fish server.fish | tee /tmp/server_output.log; touch /tmp/.server_done

# Extract contract address
grep 'Client1Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client1verifier_address
grep 'Client2Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client2verifier_address
grep 'Client3Verifier' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/client3verifier_address
grep 'PublicKeyRegistry' /tmp/server_output.log | grep -oE '0x[a-fA-F0-9]{40}' > /tmp/pkregistry_address
"' C-m

# In pane 4, start anvil nodes
tmux send-keys -t 4 'clear; anvil' C-m


# Once Pane 3 is done, restart client0-2
# contract address captured in pane 3
tmux send-keys -t 0 'bash -c "
while [ ! -f /tmp/.server_done ]; do
  echo Waiting...
  sleep 1
done
echo contract deployed
VALUE=\$(cat /tmp/pkregistry_address)
echo pkregistry contract address = \$VALUE
"' C-m

# Attach to session
tmux attach -t $SESSION