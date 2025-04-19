use ecdh::bjj::BJJ;
use ecdh::ECDHTrait;
use noir_mpc_ml::ml::train_multi_class;
use noir_mpc_ml::quantized::Quantized;

// model for each class
pub struct TrainedModelPerClass<let M: u32> {
    pub weights: [Quantized; M],
    pub bias: Quantized,
}

// multiclass model
pub struct MultiClassTrainedModel<let M: u32, let C: u32> {
    pub models: [TrainedModelPerClass<M>; C],
    pub n_samples: Quantized,
}
// N: Number of samples (e.g. Client1: 10, Client2: 10, Client3: 20)
// M: Number of features per sample (e.g. 4)
// C: Numebr of classes (e.g. 3)
pub fn train<let N: u32, let M: u32, let C: u32>(
    secret_key: Field,
    inputs: [[Quantized; M]; N],
    labels: [[Quantized; N]; C],
) {
    let epochs = 10;
    let learning_rate_ratio = Quantized::new(218);
    let parameters_train = train_multi_class(epochs, inputs, labels, learning_rate_ratio);

    let mut trained_multiclass_model: MultiClassTrainedModel<M, C> = MultiClassTrainedModel {
        models: [
            TrainedModelPerClass { weights: [Quantized::zero(); M], bias: Quantized::zero() }; C
        ],
        n_samples: Quantized::zero(),
    };

    // Populate each class model
    for i in 0..C {
        let (weights, bias) = parameters_train[i];

        trained_multiclass_model.models[i] = TrainedModelPerClass { weights, bias };
    }

    // Store the total number of samples for later aggregation
    trained_multiclass_model.n_samples = Quantized::new(Field::from(N));

    println(trained_multiclass_model);

    let ecdh = BJJ::new(secret_key);
    let pk = ecdh.derive_public_key();

    println("pk_x:");
    println(pk.x);
    println("pk_y:");
    println(pk.y);
}
