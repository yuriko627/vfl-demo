use aggregation_prover::aggregate::aggregate;
use training_prover::train::MultiClassTrainedModel;

pub fn main(submitted_models: [MultiClassTrainedModel<4, 3>; 3]) {
    let aggregated_model = aggregate(submitted_models);
    println((aggregated_model))
}
