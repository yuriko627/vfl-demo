import toml

FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617
BIT_LIMIT = 126

def adjust_field_element(val):
    """If val exceeds 126 bits, return signed equivalent using BN254 modulus."""
    if val.bit_length() > BIT_LIMIT:
        neg_val = -(FIELD_MODULUS - val)
        return neg_val
    return val

def weight(val, n_samples):
    return val * n_samples

def parse_and_adjust(file_path):
    with open(file_path, 'r') as f:
        data = toml.load(f)

    n_samples = int(data["my_model"]["n_samples"]["x"], 16)

    adjusted_models = []
    for model in data["my_model"]["models"]:
        weights = [adjust_field_element(int(w["x"], 16)) for w in model["weights"]]
        bias = adjust_field_element(int(model["bias"]["x"], 16))

        weighted_weights = [weight(w, n_samples) for w in weights]
        weighted_bias = weight(bias, n_samples)

        adjusted_models.append({
            "weights": weighted_weights,
            "bias": weighted_bias
        })

    result = {
        "priv_key": int(data["priv_key"]),
        "n_samples": n_samples,
        "models": adjusted_models
    }

    return result

def main():
    files = ["../clients/client1/masking/Prover.toml", "../clients/client2/masking/Prover.toml", "../clients/client3/masking/Prover.toml"]
    all_models = []
    total_samples = 0

    for f in files:
        adjusted = parse_and_adjust(f)
        all_models.append(adjusted["models"])
        total_samples += adjusted["n_samples"]

    #     print(f"\n===== {f} =====")
    #     print(f"priv_key: {adjusted['priv_key']}")
    #     print(f"n_samples: {adjusted['n_samples']}")
    #     for i, model in enumerate(adjusted["models"]):
    #         print(f"  Class {i}:")
    #         print(f"    Weights: {model['weights']}")
    #         print(f"    Bias: {model['bias']}")

    # Aggregate weights and biases across the 3 models per class
    print("\n===== Aggregated (Summed) Model =====")
    print(f"  Total number of samples {total_samples}")
    aggregated = []
    for class_idx in range(3):
        total_weights = [0.0] * 4
        total_bias = 0.0
        for model_group in all_models:
            for i, w in enumerate(model_group[class_idx]["weights"]):
                total_weights[i] += w
            total_bias += model_group[class_idx]["bias"]

        weighted_averaged_weights = [w / total_samples for w in total_weights]
        weighted_averaged_bias = total_bias / total_samples

        aggregated.append({
            "weights": weighted_averaged_weights,
            "bias": weighted_averaged_bias
        })

        print(f"  Class {class_idx}:")
        print(f"    Weights: {weighted_averaged_weights}")
        print(f"    Bias: {weighted_averaged_bias}")

if __name__ == "__main__":
    main()


