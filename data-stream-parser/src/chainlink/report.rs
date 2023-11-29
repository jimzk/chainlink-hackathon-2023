use std::{fmt, str::FromStr};

use alloy_primitives::I256;
use alloy_sol_types::{sol, SolValue};
use num_bigint::{BigInt, BigUint};
use secp256k1::{
    ecdsa::{RecoverableSignature, RecoveryId, Signature},
    Message, PublicKey,
};
use sha3::{Digest, Keccak256};

pub type Bytes32 = [u8; 32];

#[derive(Debug, Clone)]
pub struct FullReport {
    pub report_context: [Bytes32; 3],
    pub report_blob: Vec<u8>,
    pub raw_rs: Vec<Bytes32>,
    pub raw_ss: Vec<Bytes32>,
    pub raw_vs: Bytes32,
}

sol! {
    struct SolFullReport {
        bytes32[3] report_context;
        bytes report_blob;
        bytes32[] raw_rs;
        bytes32[] raw_ss;
        bytes32 raw_vs;
    }
}

impl From<SolFullReport> for FullReport {
    fn from(value: SolFullReport) -> Self {
        FullReport {
            report_context: value
                .report_context
                .into_iter()
                .map(|r| r.into())
                .collect::<Vec<_>>()
                .try_into()
                .unwrap(),
            report_blob: value.report_blob,
            raw_rs: value.raw_rs.into_iter().map(|r| r.into()).collect(),
            raw_ss: value.raw_ss.into_iter().map(|r| r.into()).collect(),
            raw_vs: value.raw_vs.into(),
        }
    }
}

impl From<FullReport> for SolFullReport {
    fn from(value: FullReport) -> Self {
        SolFullReport {
            report_context: value
                .report_context
                .into_iter()
                .map(|r| r.into())
                .collect::<Vec<_>>()
                .try_into()
                .unwrap(),
            report_blob: value.report_blob,
            raw_rs: value.raw_rs.into_iter().map(|r| r.into()).collect(),
            raw_ss: value.raw_ss.into_iter().map(|r| r.into()).collect(),
            raw_vs: value.raw_vs.into(),
        }
    }
}

impl FullReport {
    pub fn abi_encode(&self) -> Vec<u8> {
        let sol_type = SolFullReport::from(self.clone());
        sol_type.abi_encode_params()
    }

    pub fn abi_decode(data: &[u8]) -> Self {
        let sol_type = SolFullReport::abi_decode_params(data, true).unwrap();
        sol_type.into()
    }

    // https://github.com/smartcontractkit/chainlink/blob/e623afd8079d0875301df33acf74f75e989abcde/contracts/src/v0.8/llo-feeds/Verifier.sol#L284-L309
    pub fn recover_publickey(&self) -> (Vec<(Signature, PublicKey)>, Message) {
        let hashed_report = {
            let mut hasher = <Keccak256 as Digest>::new();
            Digest::update(&mut hasher, &self.report_blob);
            Digest::finalize(hasher)
        };
        let hash = {
            let content: ([u8; 32], _) = (hashed_report.into(), self.report_context);
            let abi_encoded = content.abi_encode_packed();
            let mut hasher = <Keccak256 as Digest>::new();
            Digest::update(&mut hasher, &abi_encoded);
            Digest::finalize(hasher)
        };
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
        (recovered, msg)
    }

    pub fn report(&self) -> V2Report {
        let report = V2Report::abi_decode(&self.report_blob);
        report
    }
}

#[derive(Debug, Clone)]
pub struct V2Report {
    feed_id: Bytes32,
    valid_from_timestamp: u32,
    observations_timestamp: u32,
    native_fee: BigUint,
    link_fee: BigUint,
    expires_at: u32,
    benchmark_price: BigInt,
}

sol! {
    struct SolV2Report {
        bytes32 feed_id;
        uint32  valid_from_timestamp;
        uint32  observations_timestamp;
        uint192 native_fee;
        uint192 link_fee;
        uint32  expires_at;
        int192  benchmark_price;
    }
}

impl From<SolV2Report> for V2Report {
    fn from(value: SolV2Report) -> Self {
        V2Report {
            feed_id: value.feed_id.into(),
            valid_from_timestamp: value.valid_from_timestamp,
            observations_timestamp: value.observations_timestamp,
            native_fee: BigUint::from_str(&value.native_fee.to_string()).unwrap(),
            link_fee: BigUint::from_str(&value.link_fee.to_string()).unwrap(),
            expires_at: value.expires_at,
            benchmark_price: BigInt::from_str(&value.benchmark_price.to_string()).unwrap(),
        }
    }
}

impl From<V2Report> for SolV2Report {
    fn from(value: V2Report) -> Self {
        use alloy_primitives::U256;
        SolV2Report {
            feed_id: value.feed_id.into(),
            valid_from_timestamp: value.valid_from_timestamp,
            observations_timestamp: value.observations_timestamp,
            native_fee: U256::from_str(&value.native_fee.to_str_radix(10)).unwrap(),
            link_fee: U256::from_str(&value.link_fee.to_str_radix(10)).unwrap(),
            expires_at: value.expires_at,
            benchmark_price: I256::from_str(&value.benchmark_price.to_str_radix(10)).unwrap(),
        }
    }
}

impl fmt::Display for V2Report {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let dislay = format!(
            r#"{{
    "feed_id": "{}",
    "valid_from_timestamp": {}, 
    "observations_timestamp": {},
    "native_fee": "{}",
    "link_fee": "{}", 
    "expires_at": {}, 
    "benchmark_price": "{}"
}}"#,
            hex::encode(self.feed_id),
            self.valid_from_timestamp,
            self.observations_timestamp,
            self.native_fee.to_str_radix(10),
            self.link_fee.to_str_radix(10),
            self.expires_at,
            self.benchmark_price.to_str_radix(10)
        );
        write!(f, "{}", dislay)
    }
}

impl V2Report {
    pub fn abi_encode(&self) -> Vec<u8> {
        let sol_type = SolV2Report::from(self.clone());
        sol_type.abi_encode_params()
    }

    pub fn abi_decode(data: &[u8]) -> Self {
        let sol_type = SolV2Report::abi_decode_params(data, true).unwrap();
        sol_type.into()
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
        println!("report: {}", report);
        println!("----------");
        let decoded = report.abi_encode();
        println!("hex decoded: {:?}", hex::encode(&decoded));
        println!("hex data: {:?}", hex::encode(&data));
        assert_eq!(data, decoded);
    }
}
