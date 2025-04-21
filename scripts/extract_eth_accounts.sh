#!/bin/bash

# Validate input
if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 [address|privatekey] <index>"
  exit 1
fi

what="$1"
index="$2"

if [[ "$what" != "address" && "$what" != "privatekey" ]]; then
  echo "First argument must be 'address' or 'privatekey'"
  exit 1
fi

if ! [[ "$index" =~ ^[0-9]+$ ]]; then
  echo "Second argument must be a number"
  exit 1
fi

log_file="/tmp/anvil_log"

# Flatten the log to fix wrapping issues
flattened_log=$(tr -d '\n' < "$log_file")

# Extract public addresses
addresses=()
while IFS= read -r addr; do
  addresses+=("$addr")
done < <(echo "$flattened_log" | grep -Eo '0x[0-9a-fA-F]{40}' | head -n 10)

# Extract private keys
private_keys=()
while IFS= read -r key; do
  private_keys+=("$key")
done < <(echo "$flattened_log" | grep -Eo '0x[0-9a-fA-F]{64}' | head -n 10)

# Return requested value
if [[ "$what" == "address" ]]; then
  echo "${addresses[$index]}"
else
  echo "${private_keys[$index]}"
fi





