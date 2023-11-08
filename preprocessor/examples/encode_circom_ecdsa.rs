use secp256k1::{ecdsa::Signature, Message, Secp256k1};

// Decode input of secp256k1 verification circom from
// https://github.com/0xPARC/circom-ecdsa/blob/master/scripts/verify/input_verify.json
fn main() {
    let secp = Secp256k1::new();
    let m = [
        7828219513492386041,
        3988479630986735061,
        17828618373474417767,
        7725776341465200115,
    ];
    let m = to_32_bytes(m);
    let message = Message::from_digest(m);

    let pub_key_x: [u64; 4] = [
        15936664623177566288,
        3250397285527463885,
        12867682233480762946,
        7876377878669208042,
    ];
    let pub_key_y: [u64; 4] = [
        17119974326854866418,
        4804456518640350784,
        12443422089272457229,
        9048921188902050084,
    ];
    let pub_key_x = to_32_bytes(pub_key_x);
    let pub_key_y = to_32_bytes(pub_key_y);
    let pub_key_bytes = [&[04u8][..], &pub_key_x[..], &pub_key_y[..]].concat();
    let pub_key = secp256k1::PublicKey::from_slice(&pub_key_bytes).unwrap();

    let r = [
        11878389131962663075,
        9922462056030557342,
        6756396965793543634,
        12446269625364732260,
    ];
    let s = [
        18433728439776304144,
        9948993517021512060,
        8616204783675899344,
        12630110559440107129,
    ];
    let r = to_32_bytes(r);
    let s = to_32_bytes(s);
    let signature = [r, s].concat();
    let mut signature = Signature::from_compact(&signature).unwrap();
    signature.normalize_s();

    let result = secp.verify_ecdsa(&message, &signature, &pub_key).is_ok();
    println!("secp256k1 ECDSA verification result: {}", result);
}

fn to_32_bytes(m: [u64; 4]) -> [u8; 32] {
    m.clone()
        .into_iter()
        .rev()
        .map(|m| m.to_be_bytes())
        .flatten()
        .collect::<Vec<_>>()
        .try_into()
        .unwrap()
}
