pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

template IsNotZero() {
    signal input in;
    signal output out;

    component isZero = IsZero();
    isZero.in <== in;

    component not = NOT();
    not.in <== isZero.out;

    out <== not.out;
}
