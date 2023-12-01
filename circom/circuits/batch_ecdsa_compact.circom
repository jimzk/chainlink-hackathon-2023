pragma circom 2.0.4;

include "ecdsa/sha256.circom";
include "ecdsa/eth_addr.circom";
include "ecdsa-batch/batch_ecdsa.circom";

template BatchECDSAVerifyNoPubkeyCheckCompact(n, k, b) {
    component batchEcdsa = BatchECDSAVerifyNoPubkeyCheck(n, k, b);
    signal input r[b][k];
    signal input rprime[b][k];
    signal input s[b][k];
    signal input msghash[b][k];
    signal input pubkey[b][2][k];
    signal output result;
    signal output msgHashesHash[2];
    signal output pubkeyHash[b];

    r ==> batchEcdsa.r;
    rprime ==> batchEcdsa.rprime;
    s ==> batchEcdsa.s;
    msghash ==> batchEcdsa.msghash;
    pubkey ==> batchEcdsa.pubkey;

    result <== batchEcdsa.result;

    signal aggregatedMsgHashBits[b * 256];
    component num2bits[b][k];
    // Little endian, including bytes and bits order
    for (var i = 0; i < b; i ++) {
        for (var j = 0; j < k; j++) {
            num2bits[i][j] = Num2Bits(n);
            num2bits[i][j].in <== msghash[i][j];
            var jj = k - 1 - j;
            for (var l = 0; l < n; l++) { // n = 64
                var ll = n - 1 - l;
                aggregatedMsgHashBits[i * n * k + jj * n + ll] <== num2bits[i][j].out[l];
            }
        }
    }
    component sha256Num = Sha256Num(b * 256);  // n * k = 256
    for (var i = 0; i < b * 256; i++) {
        sha256Num.in[i] <== aggregatedMsgHashBits[i];
    }
    msgHashesHash <== sha256Num.out;

    component ethAddr[b];
    for (var i = 0; i < b; i++) {
        ethAddr[i] = PubKeyToAddr(n, k);
        ethAddr[i].pubkey <== pubkey[i];
        pubkeyHash[i] <== ethAddr[i].addr;
    }
}
