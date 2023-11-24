use std::str::FromStr;

use ethabi::{ethereum_types::U256, ParamType, Token};
use num_bigint::{BigInt, BigUint};
use secp256k1::{
    ecdsa::{RecoverableSignature, RecoveryId, Signature},
    Message, PublicKey,
};
use sha3::{Digest, Keccak256};

pub type Bytes32 = [u8; 32];

#[derive(Debug)]
pub struct FullReport {
    report_context: [Bytes32; 3],
    report_blob: Vec<u8>,
    raw_rs: Vec<Bytes32>,
    raw_ss: Vec<Bytes32>,
    raw_vs: Bytes32,
}

impl FullReport {
    fn get_abi_type() -> Vec<ParamType> {
        let mut types: Vec<ParamType> = vec![];
        types.push(ParamType::FixedArray(
            Box::new(ParamType::FixedBytes(32)),
            3,
        ));
        types.push(ParamType::Bytes);
        types.push(ParamType::Array(Box::new(ParamType::FixedBytes(32))));
        types.push(ParamType::Array(Box::new(ParamType::FixedBytes(32))));
        types.push(ParamType::FixedBytes(32));
        types
    }

    fn to_abi_token(&self) -> Vec<Token> {
        let mut tokens = vec![];
        let report_context = self
            .report_context
            .into_iter()
            .map(|t| Token::FixedBytes(t.to_vec()))
            .collect::<Vec<Token>>();
        tokens.push(Token::FixedArray(report_context));
        let report_blob = Token::Bytes(self.report_blob.clone());
        tokens.push(report_blob);
        let raw_rs = self
            .raw_rs
            .iter()
            .map(|t| Token::FixedBytes(t.clone().to_vec()))
            .collect::<Vec<Token>>();
        tokens.push(Token::Array(raw_rs));
        let raw_ss = self
            .raw_ss
            .iter()
            .map(|t| Token::FixedBytes(t.to_vec()))
            .collect::<Vec<Token>>();
        tokens.push(Token::Array(raw_ss));
        let raw_vs = Token::FixedBytes(self.raw_vs.to_vec());
        tokens.push(raw_vs);
        tokens
    }

    fn from_abi_token(tokens: Vec<Token>) -> Self {
        let report_context: Vec<[u8; 32]> = tokens
            .get(0)
            .unwrap()
            .clone()
            .into_fixed_array()
            .unwrap()
            .into_iter()
            .map(|r| r.into_fixed_bytes().unwrap().try_into().unwrap())
            .collect();
        let report_blob = tokens.get(1).unwrap().clone().into_bytes().unwrap();
        let raw_rs = tokens
            .get(2)
            .unwrap()
            .clone()
            .into_array()
            .unwrap()
            .into_iter()
            .map(|r| r.into_fixed_bytes().unwrap().try_into().unwrap())
            .collect();
        let raw_ss = tokens
            .get(3)
            .unwrap()
            .clone()
            .into_array()
            .unwrap()
            .into_iter()
            .map(|r| r.into_fixed_bytes().unwrap().try_into().unwrap())
            .collect();
        let raw_vs = tokens
            .get(4)
            .unwrap()
            .clone()
            .into_fixed_bytes()
            .unwrap()
            .try_into()
            .unwrap();

        FullReport {
            report_context: report_context.try_into().unwrap(),
            report_blob,
            raw_rs,
            raw_ss,
            raw_vs,
        }
    }

    pub fn abi_encode(&self) -> Vec<u8> {
        ethabi::encode(&self.to_abi_token())
    }

    pub fn abi_decode(data: &[u8]) -> Self {
        let tokens = ethabi::decode(&Self::get_abi_type(), data).unwrap();
        Self::from_abi_token(tokens)
    }

    // https://github.com/smartcontractkit/chainlink/blob/e623afd8079d0875301df33acf74f75e989abcde/contracts/src/v0.8/llo-feeds/Verifier.sol#L284-L309
    pub fn recover_publickey(&self) -> Vec<(Signature, PublicKey)> {
        let mut hasher = <Keccak256 as Digest>::new();
        Digest::update(&mut hasher, &self.report_context[0]);
        let hash = Digest::finalize(hasher);
        // hasher::<as Digest>::update(&self.report_blob);
        // let hash = hasher.finalize();
        let msg = Message::from_digest_slice(&hash).unwrap();
        let mut recovered = vec![];
        for i in 0..self.raw_rs.len() {
            let signature = {
                let mut bytes = [0u8; 64];
                bytes[0..32].copy_from_slice(&self.raw_rs[i]);
                bytes[32..64].copy_from_slice(&self.raw_ss[i]);
                let recover_id = RecoveryId::from_i32(self.raw_vs[0] as i32).unwrap();
                RecoverableSignature::from_compact(&bytes, recover_id).unwrap()
            };
            let pubkey = signature.recover(&msg).unwrap();
            recovered.push((signature.to_standard(), pubkey));
        }
        recovered
    }
}

#[derive(Debug)]
pub struct V2Report {
    feed_id: Bytes32,
    valid_from_timestamp: u32,
    observations_timestamp: u32,
    native_fee: BigUint,
    link_fee: BigUint,
    expires_at: u32,
    benchmark_price: BigInt,
}

impl V2Report {
    fn get_abi_type() -> Vec<ParamType> {
        let mut types: Vec<ParamType> = vec![];
        types.push(ParamType::FixedBytes(32));
        types.push(ParamType::Uint(32));
        types.push(ParamType::Uint(32));
        types.push(ParamType::Uint(192));
        types.push(ParamType::Uint(192));
        types.push(ParamType::Uint(32));
        types.push(ParamType::Int(192));
        types
    }

    fn to_abi_token(&self) -> Vec<Token> {
        let feed_id = Token::FixedBytes(self.feed_id.to_vec());
        let valid_from_timestamp = Token::Uint(self.valid_from_timestamp.into());
        let observations_timestamp = Token::Uint(self.observations_timestamp.into());
        let native_fee =
            Token::Uint(U256::from_dec_str(&self.native_fee.to_str_radix(10)).unwrap());
        let link_fee = Token::Uint(U256::from_dec_str(&self.link_fee.to_str_radix(10)).unwrap());
        let expires_at = Token::Uint(self.expires_at.into());
        let benchmark_price =
            Token::Uint(U256::from_dec_str(&self.benchmark_price.to_str_radix(10)).unwrap());
        vec![
            feed_id,
            valid_from_timestamp,
            observations_timestamp,
            native_fee,
            link_fee,
            expires_at,
            benchmark_price,
        ]
    }

    fn from_abi_token(tokens: Vec<Token>) -> Self {
        let feed_id = tokens
            .get(0)
            .unwrap()
            .clone()
            .into_fixed_bytes()
            .unwrap()
            .try_into()
            .unwrap();
        let valid_from_timestamp = tokens.get(1).unwrap().clone().into_uint().unwrap().as_u32();
        let observations_timestamp = tokens.get(2).unwrap().clone().into_uint().unwrap().as_u32();
        let native_fee = tokens.get(3).unwrap().clone().into_uint().unwrap();
        let link_fee = tokens.get(4).unwrap().clone().into_uint().unwrap();
        let expires_at = tokens.get(5).unwrap().clone().into_uint().unwrap().as_u32();
        let benchmark_price = tokens.get(6).unwrap().clone().into_int().unwrap();

        V2Report {
            feed_id,
            observations_timestamp,
            benchmark_price: BigInt::from_str(&benchmark_price.to_string()).unwrap(),
            valid_from_timestamp,
            expires_at,
            link_fee: BigUint::from_str(&link_fee.to_string()).unwrap(),
            native_fee: BigUint::from_str(&native_fee.to_string()).unwrap(),
        }
    }

    pub fn abi_encode(&self) -> Vec<u8> {
        ethabi::encode(&self.to_abi_token())
    }

    pub fn abi_decode(data: &[u8]) -> Self {
        let tokens = ethabi::decode(&Self::get_abi_type(), data).unwrap();
        println!("tokens: {:?}", tokens);
        Self::from_abi_token(tokens)
    }
}

#[cfg(test)]
mod tests {
    use super::FullReport;
    use super::V2Report;

    #[test]
    fn test_full_report() {
        let data = hex::decode("0006015a2de20abc8c880eb052a09c069e4edf697529d12eeae88b7b6867fc8100000000000000000000000000000000000000000000000000000000080f7906000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000240000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e68300000000000000000000000000000000000000000000000000000000655ac7af00000000000000000000000000000000000000000000000000000000655ac7af000000000000000000000000000000000000000000000000000000000000138800000000000000000000000000000000000000000000000000000000000a1f6800000000000000000000000000000000000000000000000000000000655c192f000000000000000000000000000000000000000000000000d130d9ecefeaae300000000000000000000000000000000000000000000000000000000000000002d1e3d8b8c581a7ed9cfc41316f1bb8598d98237fc8278a01a9c6a323c4b5c33138ef50778560ec2bb08b23960e3d74f1ffe83b9240a39555c6eb817e3f68302c00000000000000000000000000000000000000000000000000000000000000027fb9c59cc499a4672f1481a526d01aa8c01380dcfa0ea855041254d3bcf455362ce612a86846a7cbb640ddcd3abdecf56618c7b24cf96242643d5c355dee5f0e").unwrap();

        let full_report = FullReport::abi_decode(&data);
        let _ = full_report.recover_publickey();
        let decoded = full_report.abi_encode();
        assert_eq!(data, decoded);
    }
    #[test]
    fn test_v2report() {
        let data = hex::decode("0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e68300000000000000000000000000000000000000000000000000000000655ac7af00000000000000000000000000000000000000000000000000000000655ac7af000000000000000000000000000000000000000000000000000000000000138800000000000000000000000000000000000000000000000000000000000a1f6800000000000000000000000000000000000000000000000000000000655c192f000000000000000000000000000000000000000000000000d130d9ecefeaae30").unwrap();

        println!("----------");
        let report = V2Report::abi_decode(&data);
        println!("report: {:?}", report);
        println!("----------");
        let decoded = report.abi_encode();
        println!("hex decoded: {:?}", hex::encode(&decoded));
        println!("hex data: {:?}", hex::encode(&data));
        assert_eq!(data, decoded);
    }
}
