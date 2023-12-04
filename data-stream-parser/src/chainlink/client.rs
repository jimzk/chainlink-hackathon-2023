use std::env;

use reqwest::{blocking::Client, Url};

pub fn get_data_stream_report(feed_id: &str, timestamp: i64) -> serde_json::Value {
    let client_id = env::var("CLIENT_ID").expect("environment variable CLIENT_ID");
    let client_secret = env::var("CLIENT_SECRET").expect("environment variable CLIENT_SECRET");
    let base_url =
        env::var("BASE_URL").unwrap_or("https://api.testnet-dataengine.chain.link".to_string());
    let current_timestamp_millis = now_timestamp_millis();
    let url = {
        let mut url = Url::parse_with_params(
            &base_url,
            &[("feedID", feed_id), ("timestamp", &timestamp.to_string())],
        )
        .unwrap();
        let path = "/api/v1/reports";
        url.set_path(path);
        url
    };
    let hmac = generate_hmac(
        "GET",
        &format!("{}?{}", url.path(), url.query().unwrap()),
        None,
        &client_id,
        &client_secret,
        current_timestamp_millis,
    );

    let client = Client::new();
    let req = client
        .get(url)
        .header("AUTHORIZATION", client_id)
        .header(
            "X-Authorization-Timestamp",
            current_timestamp_millis.to_string(),
        )
        .header("X-Authorization-Signature-Sha256", hmac)
        .send()
        .unwrap();
    req.json::<serde_json::Value>().unwrap()
}

fn generate_hmac(
    method: &str,
    path: &str,
    body: Option<&[u8]>,
    client_id: &str,
    user_secret: &str,
    timestamp: i64,
) -> String {
    use hmac::{Hmac, Mac};
    use sha2::{Digest, Sha256};
    type HmacSha256 = Hmac<Sha256>;
    let mut server_body_hash = Sha256::new();
    server_body_hash.update(body.unwrap_or_default());
    let server_body_hash_string = format!(
        "{} {} {} {} {}",
        method,
        path,
        hex::encode(server_body_hash.finalize()),
        client_id,
        timestamp
    );
    let mut mac = HmacSha256::new_from_slice(user_secret.as_bytes()).unwrap();
    mac.update(server_body_hash_string.as_bytes());
    let hmac_digest = hex::encode(mac.finalize().into_bytes());
    hmac_digest
}

fn now_timestamp_millis() -> i64 {
    let start = std::time::SystemTime::now();
    let since_the_epoch = start
        .duration_since(std::time::UNIX_EPOCH)
        .expect("Time went backwards");
    since_the_epoch.as_millis() as i64
}

#[cfg(test)]
mod tests {
    use super::get_data_stream_report;
    use crate::chainlink::report::{FullReport, V2Report};
    #[test]
    fn test_generate_hmac() {
        let method = "GET";
        let path = "/api/v1/reports?feedID=0x0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e683&timestamp=1700448175";
        let body = None;
        let timestamp = 1700792108385;
        let client_id = "client_id";
        let user_secret = "user_secret";
        let hmac = super::generate_hmac(method, path, body, client_id, user_secret, timestamp);
        assert_eq!(
            hmac,
            "a800c3086821faff8b5f6c772660b8c449041a73fe5f4e81105141cf595eb696"
        )
    }

    #[test]
    fn test_get_report() {
        let report = get_data_stream_report(
            "0x0002191c50b7bdaf2cb8672453141946eea123f8baeaa8d2afa4194b6955e683",
            1700448175,
        );
        println!("report {:#?}", report);
        println!("{:#?}", report["report"]["fullReport"].as_str().unwrap());
        let data = report["report"]["fullReport"].as_str().unwrap();
        let data = data.trim_start_matches("0x");
        let full_report = FullReport::abi_decode(&hex::decode(data).unwrap());
        let report = V2Report::abi_decode(&full_report.report_blob);
        println!("report {:#?}", report);
    }
}
