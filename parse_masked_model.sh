#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./parse_masked_model.sh '<your model string>'"
    exit 1
fi

input_string="$1"

# Extract all hex values (0x-prefixed)
hex_values=()
while read -r val; do
    hex_values+=("$val")
done < <(echo "$input_string" | grep -oE '0x[0-9a-fA-F]+')

# Expect exactly 16 values: 3 classes * (4 weights + 1 bias) + 1 n_samples
if [ "${#hex_values[@]}" -ne 16 ]; then
    echo "Expected 16 quantized values (5 values x 3 classes + 1), got ${#hex_values[@]}"
    exit 1
fi

val_index=0
class_strs=()

# Process 3 classes
for class_index in 1 2 3; do
    w1="${hex_values[$val_index]}"
    w2="${hex_values[$((val_index + 1))]}"
    w3="${hex_values[$((val_index + 2))]}"
    w4="${hex_values[$((val_index + 3))]}"
    bias="${hex_values[$((val_index + 4))]}"
    val_index=$((val_index + 5))

    class_fmt="([$w1,$w2,$w3,$w4],$bias)"
    class_strs+=("$class_fmt")
done

# Join class tuples with commas
joined_classes=$(IFS=, ; echo "${class_strs[*]}")

# Get the final n_samples value (last element)
n_samples="${hex_values[15]}"

# Build and print the final model string
model_str="([$joined_classes],$n_samples)"
echo "$model_str"

