#!/usr/bin/env fish

if test (count $argv) -ne 1
    echo "Usage: ./parse_fetched_model.fish '<your model string>'"
    return 1
end

set input_string $argv[1]

# Remove scientific notations
set cleared_string (string replace -ra ' \[[0-9]\.[0-9]{2,3}e[0-9]{2}\]' '' -- $input_string)

# Extract all numbers and put them in an array
set -g numbers_array (string match -ra '[0-9]+' -- $cleared_string)

set -g reordered_array

for chunk_start in 1 17 33
    set chunk_end (math $chunk_start + 15)
    set chunk $numbers_array[$chunk_start..$chunk_end]

    # s is the last element in this 16-element chunk
    set s $chunk[-1]

    # all other values before the s (i.e., models)
    set models $chunk[1..15]

    # Append reordered: s + models
    set reordered_array $reordered_array $s $models
end

# Initialize index
set -g idx 1

# Helper function to pull next number and increment index
function next_number
    set -g current $reordered_array[$idx]
    set -g idx (math $idx + 1)
end


# Generate TOML structure
for i in (seq 1 3)  # 3 blocks total
	echo "[[submitted_models]]"
    next_number
    echo "n_samples = { x = \"$current\" }"
    echo

    for j in (seq 1 3)  # 3 models per block
        echo '[[submitted_models.models]]'
        echo 'weights = ['

        for k in (seq 1 4)
            next_number
            echo "    { x = \"$current\" },"
        end

        echo ']'
        next_number
        echo "bias = { x = \"$current\" }"
        echo
    end
end

