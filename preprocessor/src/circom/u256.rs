use core::fmt;

use serde::{Deserialize, Serialize};

#[derive(Default, Debug, Clone, Copy)]
pub struct U256([u8; 32]);

// Into number representation u64
impl From<U256> for [u64; 4] {
    fn from(value: U256) -> Self {
        let value: [u8; 32] = value.0;
        let value: Vec<u64> = value
            .chunks_exact(8)
            .map(|m| u64::from_be_bytes(m.try_into().unwrap()))
            .collect();
        value.try_into().unwrap()
    }
}

impl fmt::Display for U256 {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", serde_json::to_string(&self).unwrap())
    }
}

impl U256 {
    pub fn new(bytes: [u8; 32]) -> Self {
        Self(bytes)
    }

    pub fn new_from_slice(bytes: &[u8]) -> Self {
        Self(bytes.try_into().unwrap())
    }

    pub fn new_from_4u64(value: [u64; 4]) -> Self {
        let value: [u8; 32] = value
            .into_iter()
            .rev()
            .map(|m| m.to_be_bytes())
            .flatten()
            .collect::<Vec<_>>()
            .try_into()
            .unwrap();
        Self(value)
    }

    pub fn serialize(&self) -> [u8; 32] {
        self.0
    }
}

impl Serialize for U256 {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let value: [u64; 4] = self.clone().into();
        let value: Vec<String> = value
            .iter()
            .map(|m| m.to_string())
            .rev()
            .collect::<Vec<_>>()
            .try_into()
            .unwrap();
        value.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for U256 {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let u64s: [String; 4] = Deserialize::deserialize(deserializer)?;
        let u64s: [u64; 4] = u64s
            .iter()
            .map(|m| m.parse::<u64>().unwrap())
            .collect::<Vec<_>>()
            .try_into()
            .unwrap();
        Ok(Self::new_from_4u64(u64s))
    }
}

#[cfg(test)]
mod tests {
    use serde_json::Value;

    #[test]
    fn test_serde() {
        let json_text = r#"["7828219513492386041","3988479630986735061","17828618373474417767","7725776341465200115"]"#;
        let u256: super::U256 = serde_json::from_str(json_text).unwrap();
        let json_text2 = serde_json::to_string(&u256).unwrap();
        let value1: Value = serde_json::from_str(&json_text).unwrap();
        let value2: Value = serde_json::from_str(&json_text2).unwrap();
        println!("json: {}", json_text2);
        assert_eq!(json_text2, json_text);
    }
}
