#!/usr/bin/env bash

# Usage: /parse_fetched_pk.sh "<256-char-hex-string>" /path/to/Prover.toml

set -e

write_pubkeys_into_toml() {
    local raw_pk_hex="$1"
    local toml_path="$2"

    # Ensure the input is exactly 256 hex characters (128 bytes)
    if [ "${#raw_pk_hex}" -ne 256 ]; then
        echo "❌ Error: input must be 256 hex characters (128 bytes total)."
        return 1
    fi

    # Extract coordinates
    local pk_lower_x="0x${raw_pk_hex:0:64}"
    local pk_lower_y="0x${raw_pk_hex:64:64}"
    local pk_higher_x="0x${raw_pk_hex:128:64}"
    local pk_higher_y="0x${raw_pk_hex:192:64}"

    echo "✅ Parsed Keys:"
    echo "pk_lower.x = $pk_lower_x"
    echo "pk_lower.y = $pk_lower_y"
    echo "pk_higher.x = $pk_higher_x"
    echo "pk_higher.y = $pk_higher_y"
    echo ""

    # Build TOML block
    pk_block=$(cat <<EOF
[pk_lower]
x = "$pk_lower_x"
y = "$pk_lower_y"

[pk_higher]
x = "$pk_higher_x"
y = "$pk_higher_y"
EOF
)

    # If file doesn't exist, create it
    if [ ! -f "$toml_path" ]; then
        echo "📝 Creating new $toml_path"
        echo "$pk_block" > "$toml_path"
        return 0
    fi

    # Remove old pk_lower and pk_higher blocks (if any)
    tmpfile=$(mktemp)
    awk '
    BEGIN { skip = 0 }
    /^\[pk_lower\]/ { skip = 1; next }
    /^\[pk_higher\]/ { skip = 1; next }
    /^\[.*\]/ && skip == 1 && $0 !~ /^\[pk_(lower|higher)\]/ { skip = 0 }
    skip == 0 { print }
    ' "$toml_path" > "$tmpfile"

    # Append new block
    echo "$pk_block" >> "$tmpfile"
    mv "$tmpfile" "$toml_path"
    echo "✅ Parsed public keys written to $toml_path"
}

# --- Main Logic ---

if [ "$#" -ne 2 ]; then
    echo "Usage: ./parse_fetched_pk.sh <256-char-hex> <path/to/Prover.toml>"
    exit 1
fi

write_pubkeys_into_toml "$1" "$2"

