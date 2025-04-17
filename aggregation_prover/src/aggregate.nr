use noir_fixed_point::quantized::Quantized as QuantizedWithDiv; // this has a division function
use noir_mpc_ml::quantized::Quantized;
use noir_mpc_ml::utils::assert_bitsize;
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
    pub n_samples: Quantized,
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
        n_samples: Quantized::zero(),
    };

    // Loop over each model submitted by clients, stored in `submitted_models`
    for client_idx in 0..L {
        let model = submitted_models[client_idx];

        // n_samples is 20 = 5 bits at max for this demo
        assert_bitsize::<5>(model.n_samples);
        temp_aggregated_model.n_samples += model.n_samples;

        // Summing up weights at the same index for each class, submitted by different clients 0-2
        //                          |class0                     | |class1                     | |class2                     |
        // model 0 (from client 0): [w000, w001, w002, w003, b00] [w010, w011, w012, w013, b01] [w020, w021, w022, w023, b02]
        // model 1 (from client 1): [w100, w101, w102, w103, b10] [w110, w111, w112, w113, b11] [w120, w121, w122, w123, b12]
        // model 1 (from client 1): [w200, w201, w202, w203, b20] [w210, w211, w212, w213, b21] [w220, w221, w222, w223, b22]
        // aggregated model       : [w000+w100+w200, w001+w101+w201,...,b00+b10+b20]...
        for class_idx in 0..C {
            let current = model.models[class_idx];

            // Weighted sum for each weight
            for weight_idx in 0..M {
                // max input bit size for safe addition: 125 bits
                // directly perform operation on the Field elements inside the Quantized struct
                assert_bitsize::<125>(temp_aggregated_model.models[class_idx].weights[weight_idx]);
                temp_aggregated_model.models[class_idx].weights[weight_idx].x +=
                    current.weights[weight_idx].x;
            }

            // max input bit size for safe addition: 125 bits
            // directly perform operation on the Field elements inside the Quantized struct
            assert_bitsize::<125>(temp_aggregated_model.models[class_idx].bias);
            temp_aggregated_model.models[class_idx].bias.x += current.bias.x;
        }
    }

    // Initialize an mpty model, which is to be returned as a final aggregated model
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

    // Divide all the summed up weights and biases by total_samples to get weighted average
    // Since original noir_mpc_ml::quantized::Quantized does not implement division,
    // we have to cast the values to noir_fixed_point::quantized::Quantized first which has division function implemented.
    for class_idx in 0..C {
        for weight_idx in 0..M {
            aggregated_model.models[class_idx].weights[weight_idx] = castToQuantizedWithDiv(
                temp_aggregated_model.models[class_idx].weights[weight_idx],
            )
                / castToQuantizedWithDiv(temp_aggregated_model.n_samples);
        }
        aggregated_model.models[class_idx].bias = castToQuantizedWithDiv(
            temp_aggregated_model.models[class_idx].bias,
        )
            / castToQuantizedWithDiv(temp_aggregated_model.n_samples);
    }

    aggregated_model
}

