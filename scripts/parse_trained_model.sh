#!/usr/bin/env bash

# Check if input string and output file path are provided
if [ $# -lt 2 ]; then
    echo "Usage: parse_trained_model.sh <input_string> <output_file> <priv_key>" >&2
    exit 1
fi

input_string="$1"
output_file="$2"
priv_key="$3"

# Check if input string is empty
if [ -z "$input_string" ]; then
    echo "Error: Input string is empty." >&2
    exit 1
fi

# Write private key
echo "priv_key = \"$priv_key\"" > "$output_file"
if [ $? -ne 0 ]; then
    echo "Error writing priv_key to $output_file"
    exit 1
fi

echo "" >> "$output_file"

# Extract n_samples
n_samples=$(echo "$input_string" | grep -oE 'n_samples:\s*Quantized\s*\{\s*x:\s*0x[0-9a-f]+' | grep -oE '0x[0-9a-f]+' )

echo "[my_model]" >> "$output_file"
echo "n_samples =  { x = \"$n_samples\" }" >> "$output_file"
echo "" >> "$output_file"

# Extract models array content
models_content=$(echo "$input_string" | grep -oE 'models:\s*\[(.*?)\],\s*n_samples:')

if [ $? -ne 0 ] || [ -z "$models_content" ]; then
    echo "Error: Could not extract 'models: [...]' content from input string." >&2
    echo "Input String was: $input_string" >&2
    exit 1
fi

# Extract individual model blocks
model_blocks=()
while read -r block; do
    model_blocks+=("$block")
done < <(echo "$models_content" | grep -oE 'TrainedModelPerClass\s*\{.*?\}\s*\}' | tr '\n' '\0' | xargs -0 -n1)

if [ ${#model_blocks[@]} -eq 0 ]; then
    echo "Error: Could not find any 'TrainedModelPerClass { ... }' blocks." >&2
    echo "Models Content was: $models_content" >&2
    exit 1
fi

# Iterate through model blocks
for model_block_string in "${model_blocks[@]}"; do
    weights_content=$(echo "$model_block_string" | grep -oE  'weights:\s*\[(.*?)\]')
    bias_value=$(echo "$model_block_string" | grep -oE 'bias:\s*Quantized\s*\{\s*x:\s*(0x[0-9a-fA-F]+)\s*\}' | grep -oE '0x[0-9a-fA-F]+')

    if [ -z "$weights_content" ] || [ -z "$bias_value" ]; then
        echo "Warning: Skipping block due to missing weights or bias." >&2
        echo "Block String causing issue: $model_block_string" >&2
        continue
    fi

    echo "[[my_model.models]]" >> "$output_file"
    echo "weights = [" >> "$output_file"

    # Extract weight hex values
    weight_hex_values=()
    while IFS= read -r line; do
        weight_hex_values+=("$line")
    done < <(echo "$weights_content" | grep -oE '0x[0-9a-fA-F]+')

    for ((i = 0; i < ${#weight_hex_values[@]}; i++)); do
        hex_val="${weight_hex_values[$i]}"
        if [ $i -eq $((${#weight_hex_values[@]} - 1)) ]; then
            echo "    { x = \"$hex_val\" }" >> "$output_file"
        else
            echo "    { x = \"$hex_val\" }," >> "$output_file"
        fi
    done

    echo "]" >> "$output_file"
    echo "bias = { x = \"$bias_value\" }" >> "$output_file"
    echo "" >> "$output_file"
done

echo "Successfully parsed the trained model and wrote them to $output_file"
exit 0











