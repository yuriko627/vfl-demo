use noir_mpc_ml::quantized::Quantized;
use training_prover::train::train;

// Suppose client1 uses 10 samples to train a model
pub fn main(secret_key: Field, inputs: [[Quantized; 4]; 10], labels: [[Quantized; 10]; 3]) {
    train(secret_key, inputs, labels);
}
