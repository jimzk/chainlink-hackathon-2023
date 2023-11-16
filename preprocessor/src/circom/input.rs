use secp256k1::{ecdsa::Signature, Message, PublicKey};
use serde::{Deserialize, Serialize};

use super::u256::U256;

// Representation for circom circom-ecdsa input.json
// (e.g. https://github.com/0xPARC/circom-ecdsa/blob/master/scripts/verify/input_verify.json)
#[derive(Debug, Clone, Copy)]
pub struct Input {
    pub signature: Signature,
    pub pubkey: PublicKey,
    pub msghash: Message,
}

impl Input {
    pub fn new(signature: Signature, pubkey: PublicKey, msg_hash: Message) -> Self {
        Self {
            signature,
            pubkey,
            msghash: msg_hash,
        }
    }

    pub fn verify_signature(&self) -> bool {
        let secp = secp256k1::Secp256k1::new();
        let mut signature = self.signature.clone();
        signature.normalize_s();
        secp.verify_ecdsa(&self.msghash, &signature, &self.pubkey)
            .is_ok()
    }
}

#[derive(Deserialize, Serialize)]
pub(crate) struct JSONInput {
    pub(crate) r: U256,
    pub(crate) s: U256,
    pub(crate) msghash: U256,
    pub(crate) pubkey: [U256; 2],
}

impl From<Input> for JSONInput {
    fn from(value: Input) -> Self {
        let (r, s) = {
            let bytes = value.signature.serialize_compact();
            let r = U256::new_from_slice(&bytes[0..32]);
            let s = U256::new_from_slice(&bytes[32..64]);
            (r, s)
        };

        let msghash = U256::new_from_slice(value.msghash.as_ref());
        let pubkey = {
            let bytes = value.pubkey.serialize_uncompressed();
            let x = U256::new_from_slice(&bytes[1..33]);
            let y = U256::new_from_slice(&bytes[33..65]);
            [x, y]
        };
        let json_input = JSONInput {
            r,
            s,
            msghash,
            pubkey,
        };
        json_input
    }
}

impl From<JSONInput> for Input {
    fn from(value: JSONInput) -> Self {
        let r = value.r;
        let s = value.s;
        let msghash = value.msghash;
        let pubkey = {
            let mut bytes = [0u8; 65];
            bytes[0] = 4;
            let x = value.pubkey[0];
            let y = value.pubkey[1];
            bytes[1..33].copy_from_slice(&x.serialize());
            bytes[33..65].copy_from_slice(&y.serialize());
            PublicKey::from_slice(&bytes).unwrap()
        };
        let signature = {
            let mut bytes = [0u8; 64];
            bytes[0..32].copy_from_slice(&r.serialize());
            bytes[32..64].copy_from_slice(&s.serialize());
            Signature::from_compact(&bytes).unwrap()
        };
        Self {
            signature,
            pubkey,
            msghash: Message::from_digest(msghash.serialize()),
        }
    }
}

impl Serialize for Input {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let json_input: JSONInput = self.clone().into();
        json_input.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for Input {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let json_input = JSONInput::deserialize(deserializer)?;
        Ok(json_input.into())
    }
}

#[cfg(test)]
mod tests {
    use std::{fs::File, io::BufReader};

    use serde_json::Value;

    use crate::circom::input::Input;

    #[test]
    fn test_serde() {
        let file = File::open("./src/circom/tests/input.json").unwrap();
        let reader = BufReader::new(file);
        let input: Input = serde_json::from_reader(reader).unwrap();
        assert!(input.verify_signature());

        let file = File::open("./src/circom/tests/input.json").unwrap();
        let reader = BufReader::new(file);
        let value1: Value = serde_json::from_reader(reader).unwrap();
        let json_text = serde_json::to_string(&input).unwrap();
        let value2: Value = serde_json::from_str(&json_text).unwrap();
        assert_eq!(value1, value2);
    }
}
