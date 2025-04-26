# Verifiable Federated Learning CLI Demo

This CLI demo shows how *publically verifiable, private & collaborative AI training* in a decentralized network can be done, combining federated learning, zero-knowledge proof, and blockchain.

## Prerequisites

You need to install
- Foundry (to simulate interacting with blockchain):
	```
	curl -L https://foundry.paradigm.xyz | bash
	source ~/.bashrc
	foundryup
	```
	and you have to fetch forge-std submodules:
	`git submodule update --init --recursive`

- tmux (to split the terminal):
`sudo apt update && sudo apt install -y tmux`
Also before starting the demo, I recommend enabling mouse support in tmux, so you can click and scroll in panes to see the log more closely:
	```
	echo "set-option -g mouse on" >> ~/.tmux.conf
	tmux source-file ~/.tmux.conf
	```
- Noir and Barretenberg (to generate/verify zk proofs):
	- To use `nargo`
		```
		curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
		source ~/.bashrc
		noirup
		```
		I used `nargo version = 1.0.0-beta.2` in my local environment (check with `nargo --version` / change with `noirup -v <version>`)
	- To use `bb`
		```
		curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash
		source ~/.bashrc
		bbup
		```
		I used `bb version = 0.72.1` in my local environment (check with `bb --version` / change with `bbup -v <version>`)

## How to start
- Run `bash start.sh` at the root directory to start simulating 3 clients, 1 server, and local Ethereum node in 5 panes
- Run `tmux kill-session` in one of the panes to stop (you need to kill a session everytime you restart the demo)
