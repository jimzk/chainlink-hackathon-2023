pragma circom 2.0.2;

include "../../node_modules/circomlib/circuits/sha256/sha256.circom";

template Sha256Num(n) {
    signal input in[n];
    signal output out[2];
    component sha256 = Sha256(n);
    sha256.in <== in;
    component bits2num[2];
    for (var i = 0; i < 2; i++) {
        bits2num[i] = Bits2Num(128);
        for (var j = 0; j < 128; j++) {
            bits2num[i].in[j] <== sha256.out[i * 128 + j];
        }
    }
    out[0] <== bits2num[0].out;
    out[1] <== bits2num[1].out;
}
