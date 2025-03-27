use ecdh::bjj::BJJ;
use ecdh::ECDHTrait;
use noir_mpc_ml::ml::train_multi_class;
use noir_mpc_ml::quantized::Quantized;

pub struct TrainedModel<let M: u32> {
    weights: [Quantized; M],
    bias: Quantized,
    n_samples: Field, // Number of training samples used
}
// N: Number of samples (e.g. client1:10, client2:10, client3:20)
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

    let mut trained_model: [TrainedModel<M>; C] = [
        TrainedModel {
            weights: [Quantized::zero(); M],
            bias: Quantized::zero(),
            n_samples: Field::from(0),
        }; C
    ];

    // we need to add sample count so that server can calculate weighted average later
    for i in 0..C {
        let (weights, bias) = parameters_train[i];

        trained_model[i] = TrainedModel {
            weights,
            bias,
            n_samples: Field::from(N), // Add sample count here
        };
    }

    println(trained_model);

    let ecdh = BJJ::new(secret_key);
    let pk = ecdh.derive_public_key();

    println("pk_x:");
    println(pk.x);
    println("pk_y:");
    println(pk.y);
}
