use noir_fixed_point::quantized::Quantized as QuantizedWithDiv; // this has division function
use noir_mpc_ml::quantized::Quantized;
use noir_mpc_ml::utils::assert_bitsize;
use training_prover::train::MultiClassTrainedModel;
use training_prover::train::TrainedModelPerClass;

// New struct definition using QuantizedWithDiv, which has division implementation
// We switch form the original Quantized struct to this struct becuase we need to do division at the end when we do weighted average calculation
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
    // Initialize temporary empty model to accumulate weighted sums
    // We use original Quantized struct
    let mut temp_aggregated_model: MultiClassTrainedModel<M, C> = MultiClassTrainedModel {
        models: [
            TrainedModelPerClass { weights: [Quantized::zero(); M], bias: Quantized::zero() }; C
        ],
        n_samples: Field::from(0),
    };

    let mut total_samples = Field::from(0);

    // Loop over each model submitted by clients, stored in `submitted_models`
    for i in 0..L {
        println("model");
        println(i);
        let model = submitted_models[i];
        let n_samples = model.n_samples;
        total_samples += n_samples;

        println("n_samples");
        println((Quantized::new(n_samples * 65536))); // fixed scale factor of 2^16 for fixed-point arithmetic
        assert_bitsize::<21>(Quantized::new(n_samples * 65536));

        // For each class in this model
        for class_idx in 0..C {
            let current = model.models[class_idx];

            println("class_idx");
            println(class_idx);
            println(current);

            // Weighted sum for each weight
            for weight_idx in 0..M {
                println("weight");
                println(current.weights[weight_idx]);
                // since n_samples is already constrained to be < 21 bits,
                // weights can be max 125 - 21 = 104 bits
                assert_bitsize::<104>(current.weights[weight_idx]);

                // max bit size for safe addition: 125 bits
                let weighted_sum = current.weights[weight_idx] * (Quantized::new(n_samples));
                // assert_bitsize::<105>(weighted_sum);
                println("weighted sum");
                println(weighted_sum);

                temp_aggregated_model.models[class_idx].weights[weight_idx] += weighted_sum;
            }

            // Weighted add for the bias
            temp_aggregated_model.models[class_idx].bias +=
                current.bias * (Quantized::new(n_samples));
        }
    }

    println("temp aggeregated model: ");
    println(temp_aggregated_model);

    // Initialize empty model to be returned as an aggregated model
    // We need to do division so we'll use QuantizedWithDiv Struct here
    let mut aggregated_model: FinalMultiClassTrainedModel<M, C> = FinalMultiClassTrainedModel {
        models: [
            FinalTrainedModelPerClass {
                weights: [QuantizedWithDiv::zero(); M],
                bias: QuantizedWithDiv::zero(),
            }; C
        ],
        n_samples: Field::from(0),
    };

    // Divide all sums by total_samples to get weighted average
    // Since original noir_mpc_ml::quantized::Quantized does not implement division,
    // let's it to noir_fixed_point::quantized::Quantized first which has division function implemented.
    for class_idx in 0..C {
        for weight_idx in 0..M {
            aggregated_model.models[class_idx].weights[weight_idx] = castToQuantizedWithDiv(
                temp_aggregated_model.models[class_idx].weights[weight_idx],
            )
                / QuantizedWithDiv::new(total_samples);
        }
        aggregated_model.models[class_idx].bias = castToQuantizedWithDiv(
            temp_aggregated_model.models[class_idx].bias,
        )
            / QuantizedWithDiv::new(total_samples);
    }

    aggregated_model
}

