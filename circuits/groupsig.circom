pragma circom 2.0.2;

include "../node_modules/circomlib/circuits/smt/smtverifier.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "./eth_addr.circom";
include "./utils/in.circom";
include "./utils/comparators.circom";

/*
  Inputs:
  - signerList     (pub)
  - msg            (pub)
  - privkey
  - groupIncRoot   (pub)
  - groupIncProofs

  Intermediate values:
  - myAddr (supposed to be addr of privkey)
  
  Output:
  - msgAttestation
  
  Prove:
  - PrivKeyToAddr(privkey) == myAddr
  - myAddr in signerList
*/

template Main(chunkSize, chunksNumber, signersNumber, groupIncLevels) {
    assert(chunkSize * chunksNumber >= 256);
    assert(chunkSize * (chunksNumber-1) < 256);

    signal input privkey[chunksNumber];
    signal input signerList[signersNumber];
    signal input msg;

    signal input groupIncRoot;
    signal input groupIncProofs[signersNumber][groupIncLevels];

    signal myAddr;

    // check that privkey properly represents a 256-bit number
    component n2bs[chunksNumber];
    for (var i = 0; i < chunksNumber; i++) {
        n2bs[i] = Num2Bits(i == chunksNumber-1 ? 256 - (chunksNumber-1) * chunkSize : chunkSize);
        n2bs[i].in <== privkey[i];
    }

    // compute addr
    component privToAddr = PrivKeyToAddr(chunkSize, chunksNumber);
    for (var i = 0; i < chunksNumber; i++) {
        privToAddr.privkey[i] <== privkey[i];
    }
    myAddr <== privToAddr.addr;

    // verify address is one of the provided
    component inComp = IN(signersNumber);
    inComp.in <== myAddr;
    for(var i = 0; i < signersNumber; i++){
        inComp.value[i] <== signerList[i];
    }
    inComp.out === 1;

    // verify that every group's participant is participate in a Sparse Merkle Tree
    component isNotZero[signersNumber];
    component participantIncProof[signersNumber];

    for (var i = 0; i < signersNumber; i++) {
        participantIncProof[i] = SMTVerifier(groupIncLevels);

        // check if signer isn't 0
        isNotZero[i] = IsNotZero();
        isNotZero[i].in <== signerList[i];

        participantIncProof[i].enabled <== isNotZero[i].out ; 
        participantIncProof[i].fnc <== 0; // 0 - verify inclusion
        participantIncProof[i].root <== groupIncRoot;
        for (var j = 0; j < groupIncLevels; j++) { 
            participantIncProof[i].siblings[j] <== groupIncProofs[i][j];
        }
        participantIncProof[i].key <== signerList[i];
        participantIncProof[i].value <== 1;
        participantIncProof[i].oldKey <== 0;
        participantIncProof[i].oldValue <== 0;
        participantIncProof[i].isOld0 <== 0;
    }
}

component main {public [signerList, msg]} = Main(64, 4, 10, 20);