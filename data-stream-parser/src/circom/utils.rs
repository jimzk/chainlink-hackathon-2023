use super::u256::U256;
use num_bigint::BigUint;

pub fn sha256_num_from_u256(bytes: &[U256]) -> (BigUint, BigUint) {
    let bytes = bytes
        .iter()
        .map(|b| {
            let mut b = <[u64; 4]>::from(b.clone());
            b.reverse();
            b
        })
        .flatten()
        .collect::<Vec<_>>();
    for i in 0..bytes.len() {
        println!("bytes[{}] = {}", i, bytes[i]);
    }
    sha256_num_from_u64(&bytes)
}

pub fn sha256_num_from_u64(bytes: &[u64]) -> (BigUint, BigUint) {
    let bytes: Vec<_> = bytes
        .iter()
        .flat_map(|&num| num.to_le_bytes())
        .map(|b| b.reverse_bits())
        .collect::<Vec<_>>();
    use sha2::{Digest, Sha256};
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    let hash = hasher.finalize();
    let first_half = bits_to_num(&hash[0..16]);
    let second_half = bits_to_num(&hash[16..32]);
    (first_half, second_half)
}

fn sha256_num(bytes: &[u8]) -> (BigUint, BigUint) {
    use sha2::{Digest, Sha256};
    let mut hasher = Sha256::new();
    println!("hex_num = {}", hex::encode(bytes));
    hasher.update(bytes);
    let hash = hasher.finalize();
    let first_half = bits_to_num(&hash[0..16]);
    let second_half = bits_to_num(&hash[16..32]);
    (first_half, second_half)
}

// circomlib Bit2Num (Little endian)
fn bits_to_num(bytes: &[u8]) -> BigUint {
    let bytes = bytes.iter().map(|b| b.reverse_bits()).collect::<Vec<_>>();
    BigUint::from_bytes_le(&bytes)
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use num_bigint::BigUint;

    use super::super::u256::U256;

    use super::sha256_num_from_u64;
    use super::{bits_to_num, sha256_num_from_u256};

    #[test]
    fn test_bits_to_num() {
        let bytes: [u8; 2] = [0b01110110, 0b10111110];
        assert_eq!(bits_to_num(&bytes), BigUint::from(32110u64));
    }
    #[test]
    fn test_sha256_num() {
        let (first, second) = sha256_num_from_u64(&[1234, 0, 0, 0, 1234, 0, 0, 0]);
        assert_eq!(
            first,
            BigUint::from_str("244893434416519543889664441600721573634").unwrap()
        );
        assert_eq!(
            second,
            BigUint::from_str("271807061959744009967160145849401225557").unwrap()
        );
    }

    #[test]
    fn test_sha256_u256_u64() {
        let bytes = [
            17105043016749647727,
            5701361998605325075,
            1392987705434378706,
            5556261108040736076,
            3076834974760725370,
            18120500676670971410,
            12043021184502540410,
            2920022113385597452,
            9624140601341552853,
            577372893988295340,
            4582757630355041526,
            12259545538130189379,
            9015510754502857787,
            11374584350181849293,
            14408252452037248603,
            8757260512348593260,
        ];
        let (first1, second2) = sha256_num_from_u64(&bytes);
        assert_eq!(
            first1,
            BigUint::from_str("292646858573863065314069197109742365081").unwrap()
        );
        assert_eq!(
            second2,
            BigUint::from_str("107641234222073459054549882126074295246").unwrap()
        );

        let first_u256 = U256::new_from_4u64(bytes[0..4].try_into().unwrap());
        let second_u256 = U256::new_from_4u64(bytes[4..8].try_into().unwrap());
        let third_u256 = U256::new_from_4u64(bytes[8..12].try_into().unwrap());
        let fourth_u256 = U256::new_from_4u64(bytes[12..16].try_into().unwrap());
        let (first2, second2) =
            sha256_num_from_u256(&[first_u256, second_u256, third_u256, fourth_u256]);
        assert_eq!(first1, first2);
        assert_eq!(second2, second2);
    }
}
