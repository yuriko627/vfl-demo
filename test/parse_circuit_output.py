import re

# === Change this path to your input file ===
INPUT_FILE_PATH = "finaloutput.toml"

# === Quantization parameters ===
FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617
BIT_LIMIT = 126
SCALE = 2 ** 16

def parse_hex_value(hex_str):
    """Convert hex string to int."""
    return int(hex_str, 16)

def adjust_field_element(val):
    """If val exceeds 126 bits, return equivalent negative value"""
    if val.bit_length() > BIT_LIMIT:
        return -(FIELD_MODULUS - val)
    return val

def decode_fixed_point(val):
    """Adjust field element and decode it as a fixed-point number."""
    signed_val = adjust_field_element(val)
    return signed_val / SCALE

def main():
    with open(INPUT_FILE_PATH, 'r') as f:
        content = f.read()

    # Extract n_samples
    n_samples_match = re.search(r'n_samples:\s*0x([0-9a-fA-F]+)', content)
    n_samples = int(n_samples_match.group(1), 16) if n_samples_match else 0

    # Extract all models
    model_pattern = re.compile(
        r'FinalTrainedModelPerClass\s*\{\s*weights:\s*\[(.*?)\],\s*bias:\s*Quantized\s*\{\s*x:\s*0x([0-9a-fA-F]+)\s*\}\s*\}',
        re.DOTALL
    )

    weight_pattern = re.compile(r'Quantized\s*\{\s*x:\s*0x([0-9a-fA-F]+)\s*\}')

    matches = model_pattern.findall(content)

    print("===== Aggregated (Summed) Model =====")
    print(f"  Total number of samples {n_samples}")

    for idx, (weights_str, bias_hex) in enumerate(matches):
        weights_raw = [parse_hex_value(m) for m in weight_pattern.findall(weights_str)]
        bias_raw = parse_hex_value(bias_hex)

        decoded_weights = [decode_fixed_point(w) for w in weights_raw]
        decoded_bias = decode_fixed_point(bias_raw)

        print(f"  Class {idx}:")
        print(f"    Weights: {[round(w, 1) for w in decoded_weights]}")
        print(f"    Bias: {round(decoded_bias, 1)}")

if __name__ == "__main__":
    main()







