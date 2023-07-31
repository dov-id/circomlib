# Dov-ID Circomlib

This repo contains a circom circuits for groupsig that originally was written by [0xPARC](https://github.com/0xPARC/circom-ecdsa).

Some modifications was added, such as `signer_list` to inputs for specifiyng signer list instead of separated input signal for every signer. 

## Usage
1. `npm i` for installing circomlib as an npm module.
2. `./scripts/compile-circuit.sh groupsig` for the `groupsig `circuit compiling. You can find a result in `./groupsig.dev/`
3. `./scripts/generate-trusted-setup.sh 20` for generating a trusted setup. The groupsig requires 20 powers, for dev purposes, you can find a `.ptau` file [here](https://github.com/iden3/snarkjs).
3. `./scripts/export-keys groupsig 20` for exporting proving, verification keys, and contract verifier.
4. `./scripts/prove-ciruit.sh groupsig ./inputs/groupsig.json` for proof generation, where `./inputs/groupsig.json` contains an example of an inputs file.
5. `./scripts/verify-proof.sh groupsig` for the proof verification.

## Dependencies
- [Circom](https://docs.circom.io/) - `v2.0.2` or greater
- [SnarkJS](https://github.com/iden3/snarkjs) - `v0.7.0` was used 
- npm