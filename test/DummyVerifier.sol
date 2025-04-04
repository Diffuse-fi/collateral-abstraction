//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract DummyVerifier {
    uint16 constant HEADER_LENGTH = 48;
    uint16 constant ENCLAVE_REPORT_LENGTH = 384;
    uint16 constant ENCLAVE_REPORT_OFFSET_OUTPUT = 13;
    function verifyAndAttestOnChain(bytes calldata rawQuote) external payable returns (bool, bytes memory) {

        bytes memory output = new bytes(ENCLAVE_REPORT_OFFSET_OUTPUT + ENCLAVE_REPORT_LENGTH);
        for (uint i = 0; i < ENCLAVE_REPORT_LENGTH; i++) {
            output[ENCLAVE_REPORT_OFFSET_OUTPUT + i] = rawQuote[HEADER_LENGTH + i];
        }

        return (true, output);
    }

    function verifyAndAttestWithZKProof(
        bytes calldata output,    //journal
        uint8 zkCoprocessor,      // enum, we use risc0 == 1
        bytes calldata proofBytes //seal
    ) external payable returns (bool, bytes memory) {
        return (true, bytes(""));
    }
}