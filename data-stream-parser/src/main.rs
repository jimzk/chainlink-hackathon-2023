use std::{fs::File, process::Command};

use crate::{
    chainlink::{client::get_data_stream_report, report::FullReport},
    circom::batch_input,
};

pub mod chainlink;
pub mod circom;
fn main() {
    let price_num = std::env::args().nth(1).expect("no price number");
    let mut timestamps = vec![];
    for i in 0..price_num.parse::<i64>().unwrap() {
        timestamps.push(1700448180 + i * 10);
    }
    println!(
        "Getting {} prices from {} to {}",
        price_num,
        timestamps[0],
        timestamps[timestamps.len() - 1]
    );
    let feed_id = "0x0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e683";
    let mut batch_input = batch_input::BatchInput::new();
    for timestamp in timestamps {
        let value = get_data_stream_report(feed_id, timestamp);
        let data = value["report"]["fullReport"]
            .as_str()
            .unwrap()
            .trim_start_matches("0x");

        let full_report = FullReport::abi_decode(&hex::decode(data).unwrap());
        let _report = full_report.report();
        let (signature_pubkeys, digest) = full_report.recover_publickey();
        batch_input.add(
            signature_pubkeys[0].0,
            signature_pubkeys[0].1,
            digest.clone(),
        )
    }
    // let json_string = serde_json::to_string_pretty(&batch_input).unwrap();
    let filename = "./input.json";
    let output = File::create(filename).unwrap();
    serde_json::to_writer_pretty(output, &batch_input).unwrap();
    println!("Parse signatures from chainlink and save to {}", filename);

    // Generate proof
    let circom_build_dir = format!(
        "../circom-ecdsa-batch/build/batch_ecdsa_verify_{}/",
        price_num
    );
    println!("Circom_build_dir: {}", circom_build_dir);

    // Move input to circom build dir
    Command::new("mv")
        .arg("./input.json")
        .arg(&circom_build_dir)
        .status()
        .expect("failed to move input.json to circom build dir");
    println!("Move input.json to {}", &circom_build_dir);


    // Generate witness
    println!("Generating witness...");
    Command::new("node")
        .current_dir(&circom_build_dir)
        .arg(format!(
            "./batch_ecdsa_verify_{}_js/generate_witness.js",
            price_num
        ))
        .arg(format!(
            "./batch_ecdsa_verify_{}_js/batch_ecdsa_verify_{}.wasm",
            price_num, price_num
        ))
        .arg("./input.json")
        .arg("./witness.wtns")
        .status()
        .expect("failed to generate witness");
    println!("Witness is generated");

    // Generate zk proof
    // npx snarkjs groth16 verify ./vkey.json ./public.json ./proof.json
    println!("Generating proof...");
    Command::new("npx")
        .current_dir(&circom_build_dir)
        .arg("snarkjs")
        .arg("groth16")
        .arg("prove")
        .arg(format!("./batch_ecdsa_verify_{}.zkey", price_num))
        .arg("./witness.wtns")
        .arg("./proof.json")
        .arg("./public.json")
        .status()
        .expect("failed to verify proof");
    println!("Proof is generated");

    // Verify zk proof
    // npx snarkjs groth16 verify ./vkey.json ./public.json ./proof.json
    println!("Verifying proof...");
    let output = Command::new("npx")
        .current_dir(&circom_build_dir)
        .arg("snarkjs")
        .arg("groth16")
        .arg("verify")
        .arg("./vkey.json")
        .arg("./public.json")
        .arg("./proof.json")
        .output()
        .expect("failed to verify proof");
    println!("Output: {:?}", output);
}
