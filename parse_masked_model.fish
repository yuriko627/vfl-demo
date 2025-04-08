#!/usr/bin/env fish

if test (count $argv) -ne 1
    echo "Usage: ./parse_model.fish '<your model string>'"
    return 1
end

# The full model string as one argument
set -l input_string (string join ' ' $argv)

# Print to check it's correct
# echo "Input string:"
# echo $input_string

set -l hex_values (string match -ra '0x[0-9a-fA-F]+' -- $input_string)

# echo "Hex values:"
# echo $hex_values

# Total values = 3 classes * (4 weights + 1 bias) + 1 n_samples = 16
if test (count $hex_values) -ne 16
    echo "Expected 16 quantized values (5 values x 3 classes + 1), got "(count $hex_values)
    return 1
end

# TODO: parse the extracted 16 hex values into this format `([([0x1,0x2,0x3,0x4],0x5),([0x6,0x7,0x8,0x9],0xa),([0xb,0xc,0xd,0xe],0xf)],0x10)`

# Initialize
set -l val_index 1
set -l class_strs

# Format 3 classes
for class_index in (seq 1 3)
    set -l weights $hex_values[$val_index] $hex_values[(math $val_index + 1)] $hex_values[(math $val_index + 2)] $hex_values[(math $val_index + 3)]
    set -l bias $hex_values[(math $val_index + 4)]
    set val_index (math "$val_index + 5")

    set -l class_fmt "([$weights[1],$weights[2],$weights[3],$weights[4]],$bias)"
    set class_strs $class_strs $class_fmt
end

# Join 3 class tuples with commas
set -l joined_classes (string join "," $class_strs)

# Get the final n_samples value
set -l n_samples $hex_values[-1]

# Build final model string
set -l model_str "([$joined_classes],$n_samples)"

echo $model_str
