use ec::tecurve::affine::Point;
use masking_prover::mask::mask;
use training_prover::train::MultiClassTrainedModel;

pub fn main(
    my_model: MultiClassTrainedModel<4, 3>,
    priv_key: Field,
    pk_lower: Point,
    pk_higher: Point,
) {
    let masked_model = mask::<4, 3>(my_model, priv_key, pk_lower, pk_higher);

    println(masked_model)
}
