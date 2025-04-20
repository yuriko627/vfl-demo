#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./parse_fetched_model.sh '<your model string>'"
    exit 1
fi

input_string="$1"

# Remove scientific notation parts
cleared_string=$(echo "$input_string" | sed -E 's/ \[[0-9]\.[0-9]{2,3}e[0-9]{2}\]//g')

# Extract all numbers into an array
numbers_array=()
while read -r number; do
    numbers_array+=("$number")
done < <(echo "$cleared_string" | grep -oE '[0-9]+')

# Reorder into s + models per chunk
reordered_array=()
for chunk_start in 0 16 32; do
    s_index=$((chunk_start + 15))
    reordered_array+=("${numbers_array[$s_index]}")  # s first
    for i in $(seq 0 14); do
        reordered_array+=("${numbers_array[$((chunk_start + i))]}")
    done
done

# Use a global index into reordered_array
idx=0
next_number() {
    current="${reordered_array[$idx]}"
    idx=$((idx + 1))
}

# Generate TOML output
for i in 1 2 3; do
    echo "[[submitted_models]]"
    next_number
    echo "n_samples = { x = \"$current\" }"
    echo

    for j in 1 2 3; do
        echo "[[submitted_models.models]]"
        echo "weights = ["
        for k in 1 2 3 4; do
            next_number
            echo "    { x = \"$current\" },"
        done
        echo "]"
        next_number
        echo "bias = { x = \"$current\" }"
        echo
    done
done



