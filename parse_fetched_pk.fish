#!/usr/bin/env fish

function write_pubkeys_into_toml
    set raw_pk_hex $argv[1]
    set toml_path $argv[2]

    # Ensure the input is exactly 256 hex chars (128 bytes)
    if test (string length $raw_pk_hex) -ne 256
        echo "❌ Error: input must be 256 hex characters (128 bytes total)."
        return 1
    end

    # Extract parts
    set pk_lower_x 0x(string sub -s 1    -l 64 $raw_pk_hex)
    set pk_lower_y 0x(string sub -s 65   -l 64 $raw_pk_hex)
    set pk_higher_x 0x(string sub -s 129 -l 64 $raw_pk_hex)
    set pk_higher_y 0x(string sub -s 193 -l 64 $raw_pk_hex)

    echo "✅ Parsed Keys:"
    echo "pk_lower.x = $pk_lower_x"
    echo "pk_lower.y = $pk_lower_y"
    echo "pk_higher.x = $pk_higher_x"
    echo "pk_higher.y = $pk_higher_y"
    echo ""

    # Create TOML section text
    set pk_block "
[pk_lower]
x = \"$pk_lower_x\"
y = \"$pk_lower_y\"

[pk_higher]
x = \"$pk_higher_x\"
y = \"$pk_higher_y\"
"

    # Replace or insert into Prover.toml
    if not test -f $toml_path
        echo "📝 Creating new $toml_path"
        echo "$pk_block" > $toml_path
        return 0
    end

    # Remove old pk_lower and pk_higher blocks (if any)
    set tmpfile (mktemp)
    awk '
    BEGIN { skip = 0 }
    /^\[pk_lower\]/ { skip = 1 }
    /^\[pk_higher\]/ { skip = 1 }
    /^\[/ && skip == 1 && $0 !~ /^\[pk_(lower|higher)\]/ { skip = 0 }
    skip == 0 { print }
    ' $toml_path > $tmpfile

    # Append the new key blocks
    echo "$pk_block" >> $tmpfile
    mv $tmpfile $toml_path
    echo "✅ Parsed public keys written to Prover.toml"
end

# --- Main logic ---
# Usage: ./parse_pks_to_prover.fish "<256-hex-string>" /path/to/Prover.toml

if test (count $argv) -ne 2
    echo "Usage: fish parse_pks_to_prover.fish <256-char-hex> <path/to/Prover.toml>"
    exit 1
end

write_pubkeys_into_toml $argv[1] $argv[2]
