use aggregation_prover::aggregate::aggregate;
use training_prover::train::MultiClassTrainedModel;

pub fn main(submitted_models: [MultiClassTrainedModel<4, 3>; 3]) {
    let aggregated_model = aggregate(submitted_models);
    println("aggregated global model:");
    println((aggregated_model))
}
