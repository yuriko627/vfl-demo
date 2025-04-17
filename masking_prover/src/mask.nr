use ec::tecurve::affine::Point;
use ecdh::bjj::BJJ;
use ecdh::ECDHTrait;
use noir_mpc_ml::quantized::Quantized;
use noir_mpc_ml::utils::assert_bitsize;
use std::hash::poseidon::bn254::hash_2;
use training_prover::train::MultiClassTrainedModel;
use training_prover::train::TrainedModelPerClass;

fn from_be_bits_124(bits: [u1; 124]) -> Field {
    let mut acc = Field::from(0);
    let mut base = Field::from(1);

    // iterate from least significant to most significant bits
    for i in 0..124 {
        let j = 123 - i; // reverse index
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

        // copy the first 124 bits
        let mut safe_mask_bits: [u1; 124] = [0; 124];
        for j in 0..124 {
            safe_mask_bits[j] = raw_bits[j];
        }

        // convert it back to a field element
        let safe_mask = from_be_bits_124(safe_mask_bits);

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
    // Each TrainedModelPerClass has M weights + 1 bias, so we need to generate M+1 masks to hide them
    let mask_with_higher_node = generate_mask::<M + 1>(priv_key, pk_higher);
    let mask_with_lower_node = generate_mask::<M + 1>(priv_key, pk_lower);

    let mut masked_models: [TrainedModelPerClass<M>; C] =
        [TrainedModelPerClass { weights: [Quantized::zero(); M], bias: Quantized::zero() }; C];

    // these values are used later inside the loop but let's do the bitsize check earlier for circuit performance reason
    // refer to the safe addition and multiplication below
    assert_bitsize::<5>(my_model.n_samples);

    for class_idx in 0..C {
        let mut masked_weights: [Quantized; M] = [Quantized::zero(); M];

        for i in 0..M {
            // NOTE:
            // max input bits for safe multiplication: sum of the bit size of two operands <= 125 bits
            // since n_samples is already restricted to be <= 5 bits, weights can be 120 bits at most
            // max input bits for safe addition: 125 bits (weighted weights) + 124 bits (mask_higher) + 124 bits (mask_lower) = 126 bits at most, which fits into the max range for either positive or negative value
            // in terms of the encoding of positive/negative values inside BN254 field, i'm following this document: https://github.com/hashcloak/noir-mpc-ml-report/blob/main/src/fixed-point-arithmetic.md
            // skipping bitsize check for n_samples, since it's already done outside the loop at the beginning
            assert_bitsize::<120>(my_model.models[class_idx].weights[i]);
            assert_bitsize::<124>(mask_with_higher_node[i]);
            assert_bitsize::<124>(mask_with_lower_node[i]);

            // directly perform operations on the field elements
            masked_weights[i] = Quantized::new(
                my_model.models[class_idx].weights[i].x * my_model.n_samples.x
                    + mask_with_higher_node[i].x
                    - mask_with_lower_node[i].x,
            );
        }

        // NOTE:
        // max input bits for safe multiplication: sum of the bit size of two operands <= 125 bits
        // since n_samples is already restricted to be <= 5 bits, bias can be 120 bits at most
        // max input bits for safe addition: 125 bits (weighted bias) + 124 bits (mask_higher) + 124 bits (mask_lower) = 126 bits at most, which is max range for either positive or negative value
        // in terms of the encoding of positive/negative values inside BN254 field, i'm following this document: https://github.com/hashcloak/noir-mpc-ml-report/blob/main/src/fixed-point-arithmetic.md
        // skipping bitsize check for n_samples and masks, since it's already done at the beginning
        assert_bitsize::<120>(my_model.models[class_idx].bias);

        // directly perform operations on the field elements
        let masked_bias = Quantized::new(
            my_model.models[class_idx].bias.x * my_model.n_samples.x + mask_with_higher_node[M].x
                - mask_with_lower_node[M].x,
        );

        masked_models[class_idx] =
            TrainedModelPerClass { weights: masked_weights, bias: masked_bias };
    }

    MultiClassTrainedModel { models: masked_models, n_samples: my_model.n_samples }
}
