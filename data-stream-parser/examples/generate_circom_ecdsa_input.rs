use data_stream_parser::circom::input::Input;
use secp256k1::hashes::sha256;
use secp256k1::{generate_keypair, Message};

fn main() {
    let (secret_key, public_key) = generate_keypair(&mut rand::thread_rng());
    let message = Message::from_hashed_data::<sha256::Hash>("Hello World!".as_bytes());

    let sig = secret_key.sign_ecdsa(message);
    assert!(sig.verify(&message, &public_key).is_ok());

    let input = Input {
        signature: sig,
        pubkey: public_key,
        msghash: message,
    };
    let json_input = serde_json::to_string_pretty(&input).unwrap();
    // Save json string into `input.json` for circom-ecdsa
    println!("{}", json_input);
}
