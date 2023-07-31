pragma circom 2.0.2;

include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "./eth_addr.circom";
include "./utils/in.circom";

/*
  Inputs:
  - signerList (pub)
  - msg        (pub)
  - privkey

  Intermediate values:
  - myAddr (supposed to be addr of privkey)
  
  Output:
  - msgAttestation
  
  Prove:
  - PrivKeyToAddr(privkey) == myAddr
  - myAddr in signerList
*/

template Main(n, k, m) {
    assert(n * k >= 256);
    assert(n * (k-1) < 256);

    signal input privkey[k];
    signal input signerList[m];
    signal input msg;

    signal myAddr;

    // check that privkey properly represents a 256-bit number
    component n2bs[k];
    for (var i = 0; i < k; i++) {
        n2bs[i] = Num2Bits(i == k-1 ? 256 - (k-1) * n : n);
        n2bs[i].in <== privkey[i];
    }

    // compute addr
    component privToAddr = PrivKeyToAddr(n, k);
    for (var i = 0; i < k; i++) {
        privToAddr.privkey[i] <== privkey[i];
    }
    myAddr <== privToAddr.addr;

    // verify address is one of the provided
    component inComp = IN(m);
    inComp.in <== myAddr;
    for(var i = 0; i < m; i++){
        inComp.value[i] <== signerList[i];
    }
    inComp.out === 1;
}

component main {public [signerList, msg]} = Main(64, 4, 10);