use noir_fixed_point::quantized::Quantized as QuantizedWithDiv; // this has division function
use noir_mpc_ml::quantized::Quantized;
use noir_mpc_ml::utils::{assert_bitsize, scale_down};
use training_prover::train::MultiClassTrainedModel;
use training_prover::train::TrainedModelPerClass;

// New struct definition using QuantizedWithDiv, which has division implementation
// We switch form the original Quantized struct to this struct becuase we need to do division at the end for weighted average calculation
pub struct FinalTrainedModelPerClass<let M: u32> {
    pub weights: [QuantizedWithDiv; M],
    pub bias: QuantizedWithDiv,
}

// multiclass model
pub struct FinalMultiClassTrainedModel<let M: u32, let C: u32> {
    pub models: [FinalTrainedModelPerClass<M>; C],
    pub n_samples: Field,
}

pub fn castToQuantizedWithDiv(q: Quantized) -> QuantizedWithDiv {
    QuantizedWithDiv { x: q.x }
}

pub fn aggregate<let M: u32, let C: u32, let L: u32>(
    submitted_models: [MultiClassTrainedModel<M, C>; L],
) -> FinalMultiClassTrainedModel<M, C> {
    // Initialize temporary empty model to accumulate weighted sums for weights and bias
    // We use original Quantized struct
    let mut temp_aggregated_model: MultiClassTrainedModel<M, C> = MultiClassTrainedModel {
        models: [
            TrainedModelPerClass { weights: [Quantized::zero(); M], bias: Quantized::zero() }; C
        ],
        n_samples: Field::from(0),
    };

    // Loop over each model submitted by clients, stored in `submitted_models`
    for client_idx in 0..L {
        // println("client_idx");
        // println(client_idx);
        let model = submitted_models[client_idx];
        let unscaled_n_samples = Quantized::new(model.n_samples);

        // n_samples is 20 = 5 bits at max for this demo
        // println("unscaled n_samples");
        // println(unscaled_n_samples);

        assert_bitsize::<5>(unscaled_n_samples);
        temp_aggregated_model.n_samples += unscaled_n_samples.x;

        // println("total number of samples summed up so far");
        // println(temp_aggregated_model.n_samples);

        // For each class in this model
        for class_idx in 0..C {
            let current = model.models[class_idx];

            // println("class_idx");
            // println(class_idx);
            // println(current);

            // Weighted sum for each weight
            for weight_idx in 0..M {
                // println("weight");
                // println(current.weights[weight_idx]);
                // since n_samples is already constrained to be <= 5 bits,
                // weights can be 125 - 5 = 120 bits at maximum
                let unscaled_weight = Quantized { x: scale_down(current.weights[weight_idx].x) };
                // println("unscaled_weight");
                // println(unscaled_weight);
                assert_bitsize::<120>(unscaled_weight);

                let scaled_down_weighted_sum_for_weights = unscaled_weight * unscaled_n_samples;

                // println(
                //     "scaled down weighted sum for weights = unscaled weight * unscaled n_sampled / 2^16",
                // );
                // println(scaled_down_weighted_sum_for_weights);

                // NOTE: multiplication between `Quantized` outputs a result devided by 2^16 because it's intended to be
                // performed on fixed point numbers. However, since we are passing unscaled values here (in order to pass max-bitsize assertion for safe multiplication), we have to rescale the result by 2^16.
                // the other operand `weights` must be 125 - 16 = 109 bits at maximum
                assert_bitsize::<109>(scaled_down_weighted_sum_for_weights);
                let weighted_sum = scaled_down_weighted_sum_for_weights * Quantized::new(65535);

                // max input bit size for safe addition: 125 bits
                assert_bitsize::<125>(weighted_sum);
                temp_aggregated_model.models[class_idx].weights[weight_idx] += weighted_sum;
            }

            let unscaled_bias = Quantized { x: scale_down(current.bias.x) };

            // since n_samples is already constrained to be <= 5 bits,
            // bias can be 125 - 5 = 120 bits at maximum for safe multiplication
            assert_bitsize::<120>(unscaled_bias);
            let scaled_down_weighted_sum_for_bias = unscaled_bias * unscaled_n_samples;

            // NOTE: multiplication between `Quantized` outputs a result devided by 2^16 because it's intended to be
            // performed on fixed point numbers. However, since we are passing unscaled values here (in order to pass max-bitsize assertion for safe multiplication), we have to rescale the result by 2^16.
            // the other operand `weights` must be 125 - 16 = 109 bits at maximum
            assert_bitsize::<109>(scaled_down_weighted_sum_for_bias);
            let weighted_sum_for_bias = scaled_down_weighted_sum_for_bias * Quantized::new(65535);

            // max input bit size for safe addition: 125 bits
            assert_bitsize::<125>(weighted_sum_for_bias);
            temp_aggregated_model.models[class_idx].bias += weighted_sum_for_bias;
        }
    }

    // println("temp aggeregated model: ");
    // println(temp_aggregated_model);

    // Initialize empty model to be returned as a final aggregated model
    // We need to do division so we'll use QuantizedWithDiv Struct here
    let mut aggregated_model: FinalMultiClassTrainedModel<M, C> = FinalMultiClassTrainedModel {
        models: [
            FinalTrainedModelPerClass {
                weights: [QuantizedWithDiv::zero(); M],
                bias: QuantizedWithDiv::zero(),
            }; C
        ],
        n_samples: temp_aggregated_model.n_samples,
    };

    // Divide all sums by total_samples to get weighted average
    // Since original noir_mpc_ml::quantized::Quantized does not implement division,
    // let's it to noir_fixed_point::quantized::Quantized first which has division function implemented.
    for class_idx in 0..C {
        for weight_idx in 0..M {
            // println("weight_idx");
            // println(weight_idx);
            aggregated_model.models[class_idx].weights[weight_idx] = castToQuantizedWithDiv(
                temp_aggregated_model.models[class_idx].weights[weight_idx],
            )
                / QuantizedWithDiv::new(temp_aggregated_model.n_samples);
        }
        aggregated_model.models[class_idx].bias = castToQuantizedWithDiv(
            temp_aggregated_model.models[class_idx].bias,
        )
            / QuantizedWithDiv::new(temp_aggregated_model.n_samples);
    }

    aggregated_model
}

