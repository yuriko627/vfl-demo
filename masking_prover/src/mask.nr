use ec::tecurve::affine::Point;
use ecdh::bjj::BJJ;
use ecdh::ECDHTrait;
use noir_mpc_ml::quantized::Quantized;
use noir_mpc_ml::utils::assert_bitsize;
use std::hash::poseidon::bn254::hash_2;
use training_prover::train::MultiClassTrainedModel;
use training_prover::train::TrainedModelPerClass;
use std::field::bn254::decompose;

fn from_be_bits_125(bits: [u1; 125]) -> Field {
    let mut acc = Field::from(0);
    let mut base = Field::from(1);

    // iterate from least significant to most significant bits
    for i in 0..125 {
        let j = 124 - i; // reverse index
        acc += base * Field::from(bits[j] as u8);
        base = base * Field::from(2);
    }

    acc
}

pub fn generate_mask<let L: u32>(
    your_private_key: Field,
    someone_elses_public_key: Point,
) -> [Quantized; L] {
    // generate a ECDH shared key
    let ecdh = BJJ::new(your_private_key);
    let shared_key = ecdh.derive_shared_key(someone_elses_public_key);

    // use the shared key as a seed for PRG to generate a mask vector
    // required length of mask vector L = M (number of weights) + 1 (number of bias)
    let mut mask_vector: [Quantized; L] = [Quantized::zero(); L];

    for i in 0..L {
        let input = [shared_key, i.into()];
        let raw = hash_2(input); // Field element

        // convert the field value to an array of bits (Big Endian, doesn't matter though)
        let raw_bits: [u1; 254] = raw.to_be_bits();

        // copy the first 125 bits
        let mut safe_mask_bits: [u1; 125] = [0; 125];
        for j in 0..125 {
            safe_mask_bits[j] = raw_bits[j];
        }

        // convert it back to a field element
        let safe_mask = from_be_bits_125(safe_mask_bits);

        mask_vector[i] = Quantized::new(safe_mask);
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
            // Restrict the mask to be less than 125 bits, so the addition and subtraction won't overflow
            assert_bitsize::<125>(mask_with_higher_node[i]);
            assert_bitsize::<125>(mask_with_lower_node[i]);
            masked_weights[i] = my_model.models[class_idx].weights[i]
                + mask_with_higher_node[i]
                - mask_with_lower_node[i];
        }

        let masked_bias = my_model.models[class_idx].bias + mask_with_higher_node[M]
            - mask_with_lower_node[M];

        masked_models[class_idx] =
            TrainedModelPerClass { weights: masked_weights, bias: masked_bias };
    }

    MultiClassTrainedModel { models: masked_models, n_samples: my_model.n_samples }
}
