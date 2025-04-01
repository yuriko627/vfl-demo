use noir_mpc_ml::quantized::Quantized;
use training_prover::train::train;

// Client2 uses 20 samples to train a model
pub fn main(secret_key: Field, inputs: [[Quantized; 4]; 20], labels: [[Quantized; 20]; 3]) {
    train(secret_key, inputs, labels);
}
