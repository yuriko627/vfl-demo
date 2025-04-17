#!/usr/bin/env fish

# Check if input string and output file path are provided
if test (count $argv) -lt 2
    echo "Usage: parse_trained_model.fish <input_string> <output_file> <priv_key>" >&2
    exit 1
end

set input_string $argv[1]
set output_file $argv[2]
set priv_key $argv[3]

# Check if input string is empty
if test -z "$input_string"
    echo "Error: Input string is empty." >&2
    exit 1
end

# Write private key
echo "priv_key = \"$priv_key\"" > $output_file
if test $status -ne 0; echo "Error writing priv_key to $output_file"; exit 1; end

echo "" >> $output_file

# Extract n_samples
set n_samples_line (string match -r 'n_samples:\s*Quantized\s*{\s*x:\s*0x[0-9a-f]+' -- $input_string)
set n_samples (string replace -r 'n_samples:\s*Quantized\s*{\s*x:\s*' '' -- $n_samples_line)

echo "[my_model]" >> $output_file
echo "n_samples =  { x = \"$n_samples\" }" >> $output_file
echo "" >> $output_file

# Extract the content within the models: [...] array
set models_content (echo $input_string | string match -r --groups-only 'models:\s*\[(.*?)\],\s*n_samples:')

if test $status -ne 0 -o -z "$models_content"
    echo "Error: Could not extract 'models: [...]' content from input string." >&2
    echo "Input String was: $input_string" >&2 # Show the original string on error
    exit 1
end

# Find all individual 'TrainedModelPerClass { ... }' block *strings*.
set model_blocks (echo $models_content | string match -ra --groups-only '(TrainedModelPerClass\s*\{.*?\}\s*\})')

if test $status -ne 0 -o (count $model_blocks) -eq 0 # Check count instead of -z for lists
    echo "Error: Could not find any 'TrainedModelPerClass { ... }' blocks." >&2
    echo "Models Content was: $models_content" >&2
    exit 1
end

# Iterate through each model block *string* and format it for TOML
for model_block_string in $model_blocks # Renamed variable for clarity
    # Extract weights content (inside the weights: [...] brackets) from the current block string
    set weights_content (echo $model_block_string | string match -r --groups-only 'weights:\s*\[(.*?)\]')

    # Extract bias value (the hex value after x:) from the current block string
    set bias_value (echo $model_block_string | string match -r --groups-only 'bias:\s*Quantized\s*\{\s*x:\s*(0x[0-9a-fA-F]+)\s*\}')

    if test -z "$weights_content" -o -z "$bias_value"
        echo "Warning: Skipping block due to missing weights or bias." >&2
        echo "Block String causing issue: $model_block_string" >&2
        continue
    end

    # Start the TOML array element for this model
    echo "[[my_model.models]]" >> $output_file

    # --- Process Weights ---
    echo "weights = [" >> $output_file

    # Extract individual weight hex values from the weights_content
    set weight_hex_values (echo $weights_content | string match -ra --groups-only 'Quantized\s*\{\s*x:\s*(0x[0-9a-fA-F]+)\s*\}')

    set num_weights (count $weight_hex_values)
    set current_weight_index 1

    if test $num_weights -gt 0
        for hex_val in $weight_hex_values
            # Check if it's the last weight to omit the trailing comma
            if test $current_weight_index -eq $num_weights
                echo "    { x = \"$hex_val\" }" >> $output_file
            else
                echo "    { x = \"$hex_val\" }," >> $output_file
            end
            set current_weight_index (math $current_weight_index + 1)
        end
    end

    # Close the weights array
    echo "]" >> $output_file

    # --- Process Bias ---
    echo "bias = { x = \"$bias_value\" }" >> $output_file

    # Add a blank line for readability between model entries
    echo "" >> $output_file

end

echo "Successfully parsed the trained model and wrote them to $output_file"
exit 0







