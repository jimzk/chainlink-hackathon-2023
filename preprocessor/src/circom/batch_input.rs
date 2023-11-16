use k256::{
    elliptic_curve::{
        sec1::{FromEncodedPoint, ToEncodedPoint},
        CurveArithmetic, PrimeField,
    },
    EncodedPoint, ProjectivePoint, Scalar,
};
use secp256k1::{ecdsa::Signature, Message, PublicKey};
use serde::{Deserialize, Serialize};

use crate::circom::input::JSONInput;

use super::{input::Input, u256::U256};

// Representation for circom batch-ecdsa input.json
// (e.g. https://github.com/puma314/batch-ecdsa/blob/master/test/input_2.json)
#[derive(Debug, Clone)]
pub struct BatchInput {
    signatures: Vec<Signature>,
    pubkey: Vec<PublicKey>,
    msghash: Vec<Message>,
}

impl BatchInput {
    pub fn new() -> Self {
        Self {
            signatures: Vec::new(),
            pubkey: Vec::new(),
            msghash: Vec::new(),
        }
    }

    pub fn add(&mut self, signature: Signature, pubkey: PublicKey, msg_hash: Message) {
        self.signatures.push(signature);
        self.pubkey.push(pubkey);
        self.msghash.push(msg_hash);
    }

    pub fn size(&self) -> usize {
        self.signatures.len()
    }

    pub fn verify_signature_all(&self) -> bool {
        let size = self.size();
        for i in 0..size {
            if !self.verify_signature(i).unwrap() {
                return false;
            }
        }
        true
    }

    pub fn verify_signature(&self, i: usize) -> Option<bool> {
        let secp = secp256k1::Secp256k1::new();
        if i >= self.size() {
            return None;
        }
        let mut signature = self.signatures[i].clone();
        signature.normalize_s();
        Some(
            secp.verify_ecdsa(&self.msghash[i], &signature, &self.pubkey[i])
                .is_ok(),
        )
    }
}

#[derive(Default, Deserialize, Serialize)]
struct JSONBatchInput {
    r: Vec<U256>,
    s: Vec<U256>,
    rprime: Vec<U256>,
    msghash: Vec<U256>,
    pubkey: Vec<[U256; 2]>,
}

impl JSONBatchInput {
    fn add(&mut self, input: JSONInput) {
        self.r.push(input.r);
        self.s.push(input.s);
        self.msghash.push(input.msghash);
        let rprime = cal_rprime(input.r, input.s, input.msghash, input.pubkey);
        self.rprime.push(rprime);
        self.pubkey.push(input.pubkey);
    }
}

impl From<JSONBatchInput> for BatchInput {
    fn from(value: JSONBatchInput) -> Self {
        let mut batch_input = BatchInput::new();
        let len = value.r.len();
        for i in 0..len {
            let r = value.r[i];
            let s = value.s[i];
            let msghash = value.msghash[i];
            let pubkey = value.pubkey[i];
            let json_input = JSONInput {
                r,
                s,
                msghash,
                pubkey,
            };
            let input: Input = json_input.into();
            batch_input.add(input.signature, input.pubkey, input.msghash);
        }
        batch_input
    }
}

impl From<BatchInput> for JSONBatchInput {
    fn from(value: BatchInput) -> Self {
        let mut json_bactch_input = JSONBatchInput::default();
        let len = value.size();
        for i in 0..len {
            let input = Input {
                signature: value.signatures[i],
                pubkey: value.pubkey[i],
                msghash: value.msghash[i],
            };
            let json_input: JSONInput = input.into();
            json_bactch_input.add(json_input);
        }
        json_bactch_input
    }
}

/// r = hs^{-1}G + rs^{-1}P
/// return r.y
fn cal_rprime(r: U256, s: U256, msghash: U256, pubkey: [U256; 2]) -> U256 {
    let p = {
        let pubkey_x = pubkey[0].serialize();
        let pubkey_y = pubkey[1].serialize();
        let p = EncodedPoint::from_affine_coordinates(
            &pubkey[0].serialize().into(),
            &pubkey[1].serialize().into(),
            false,
        );
        ProjectivePoint::from_encoded_point(&p).unwrap()
    };
    let g = {
        let g = <k256::Secp256k1 as CurveArithmetic>::AffinePoint::GENERATOR;
        ProjectivePoint::from(g)
    };
    let s_inv = {
        let s = Scalar::from_repr(s.serialize().into()).unwrap();
        s.invert().unwrap()
    };
    let r = Scalar::from_repr(r.serialize().into()).unwrap();
    let h = Scalar::from_repr(msghash.serialize().into()).unwrap();

    let rprime = g * h * s_inv + p * r * s_inv;
    let rprime = rprime.to_affine().to_encoded_point(false);

    let y = (*rprime.y().unwrap()).into();
    U256::new(y)
}

impl Serialize for BatchInput {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let json_input: JSONBatchInput = self.clone().into();
        json_input.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for BatchInput {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let json_input = JSONBatchInput::deserialize(deserializer)?;
        Ok(json_input.into())
    }
}

#[cfg(test)]
mod tests {
    use std::{fs::File, io::BufReader};

    use serde_json::Value;

    use crate::circom::batch_input::BatchInput;

    #[test]
    fn test_serde() {
        let file = File::open("./src/circom/tests/batch_input.json").unwrap();
        let reader = BufReader::new(file);
        let batch_input: BatchInput = serde_json::from_reader(reader).unwrap();
        assert!(batch_input.verify_signature_all());

        let file = File::open("./src/circom/tests/batch_input.json").unwrap();
        let reader = BufReader::new(file);
        let value1: Value = serde_json::from_reader(reader).unwrap();
        let json_text = serde_json::to_string(&batch_input).unwrap();
        let value2: Value = serde_json::from_str(&json_text).unwrap();
        assert_eq!(value1, value2);
    }

    #[test]
    fn test_serde_multi() {
        let file = File::open("./src/circom/tests/batch_input2.json").unwrap();
        let reader = BufReader::new(file);
        let batch_input: BatchInput = serde_json::from_reader(reader).unwrap();
        assert!(batch_input.verify_signature_all());
        assert_eq!(batch_input.size(), 2);
    }
}
