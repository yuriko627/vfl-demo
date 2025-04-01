use ec::tecurve::affine::Point;
use ecdh::bjj::BJJ;
use ecdh::ECDHTrait;
use noir_mpc_ml::quantized::Quantized;
use std::hash::poseidon::bn254::hash_2;
use training_prover::train::MultiClassTrainedModel;
use training_prover::train::TrainedModelPerClass;

pub fn generate_mask<let L: u32>(
    your_private_key: Field,
    someone_elses_public_key: Point,
) -> [Field; L] {
    // generate a ECDH shared key
    let ecdh = BJJ::new(your_private_key);
    let shared_key = ecdh.derive_shared_key(someone_elses_public_key);

    // use the shared key as a seed for PRG to generate a mask vector
    // required length of mask vector L = M (number of weights) + 1 (number of bias)
    let mut mask_vector: [Field; L] = [0; L];

    for i in 0..L {
        let input = [shared_key, i.into()];
        mask_vector[i] = hash_2(input);
    }
    mask_vector
}

// take your own model (weight vector), your private key, and 2 neighboring nodes
// returns masked weight vector
pub fn mask<let M: u32, let C: u32>(
    my_model: MultiClassTrainedModel<M, C>,
    priv_key: Field,
    pk_lower: Point,
    pk_higher: Point,
) -> MultiClassTrainedModel<M, C> {
    // Each TrainedModelPerClass has M weights + 1 bias
    let mask_with_higher_node = generate_mask::<M + 1>(priv_key, pk_higher);
    let mask_with_lower_node = generate_mask::<M + 1>(priv_key, pk_lower);

    let mut masked_models: [TrainedModelPerClass<M>; C] =
        [TrainedModelPerClass { weights: [Quantized::zero(); M], bias: Quantized::zero() }; C];

    for class_idx in 0..C {
        let mut masked_weights: [Quantized; M] = [Quantized::zero(); M];

        for i in 0..M {
            masked_weights[i] = my_model.models[class_idx].weights[i]
                + Quantized::new(mask_with_higher_node[i])
                - Quantized::new(mask_with_lower_node[i]);
        }

        let masked_bias = my_model.models[class_idx].bias + Quantized::new(mask_with_higher_node[M])
            - Quantized::new(mask_with_lower_node[M]);

        masked_models[class_idx] =
            TrainedModelPerClass { weights: masked_weights, bias: masked_bias };
    }

    MultiClassTrainedModel { models: masked_models, n_samples: my_model.n_samples }
}
