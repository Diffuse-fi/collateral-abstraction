// Copyright 2025 Diffuse.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.20;

import {IAutomataDcapAttestationFee} from "./IAutomataDcapAttestationFee.sol";
import {SyntheticStablecoin} from "./SyntheticStablecoin.sol";
import {funcEnum, message} from "./Utils.sol";

contract SyntheticManagement {
    IAutomataDcapAttestationFee public sgxQuoteVerifier;
    SyntheticStablecoin public syntheticStablecoin;

    address public immutable owner;

    uint16 constant ENCLAVE_REPORT_OFFSET_OUTPUT = 13;
    uint16 constant MRENCLAVE_OFFSET = 64;
    uint16 constant REPORT_DATA_OFFSET = 320;

    bytes32 public mrEnclaveExpected;

    message[] messageDB;

    constructor() {
        owner = msg.sender;
        syntheticStablecoin = new SyntheticStablecoin();
    }

    function mrEnclaveUpdate(bytes32 mrEnclaveNew) external {
        require (msg.sender == owner, "only contract owner can call mrEnclaveUpdate");
        mrEnclaveExpected = mrEnclaveNew;
    }

    function quoteVerifierUpdate(address newQuoteVerifierAddress) external {
        require (msg.sender == owner, "only contract owner can call quoteVerifierUpdate");
        sgxQuoteVerifier = IAutomataDcapAttestationFee(newQuoteVerifierAddress);
    }

    // enclaveReport starts at ENCLAVE_REPORT_OFFSET_OUTPUT-th byte of the verification output
    function check_mrenclave(bytes memory verificationOutput) private view {
        bytes memory mrEnclaveReal = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            // mrenclave starts at byte 64 of enclaveReport and is 32 bytes long
            // https://github.com/automata-network/automata-dcap-attestation/blob/3a854a31eb2345a31f9e33697eef0d814d031a12/evm/contracts/bases/QuoteVerifierBase.sol#L64-L76
            mrEnclaveReal[i] = verificationOutput[ENCLAVE_REPORT_OFFSET_OUTPUT + 64 + i];
        }
        require (bytes32(mrEnclaveReal) == mrEnclaveExpected, "mrEnclave from input differs from expected!");
    }

    function nonceAssert(uint80 nonce) internal view {
        require (messageDB.length == nonce, "message nonce and messageBD.length are not equal");
    }

    function processMessageZk(
        uint256 usdAmount,    // storage slot 1
        uint256 storageSlot2, // storage slot 2
        bytes calldata sgx_verification_journal,
        bytes calldata sgx_verification_seal
    ) external payable {

        (bool success, bytes memory output) = sgxQuoteVerifier.verifyAndAttestWithZKProof{value: msg.value}(sgx_verification_journal, 1, sgx_verification_seal);
        // fail returns bytes(error_string)
        // success returns custom output type:
        // https://github.com/automata-network/automata-dcap-attestation/blob/b49a9f296a5e0cd8b1f076ec541b1239199cadd2/contracts/verifiers/V3QuoteVerifier.sol#L154
        require(success, string(output));
        processMessage(output, usdAmount, storageSlot2);
    }

    function processMessageOnchain(
        uint256 usdAmount,   // storage slot 1
        uint256 storageSlot2, // storage slot 2
        bytes calldata sgx_quote
    ) external payable {

        (bool success, bytes memory output) = sgxQuoteVerifier.verifyAndAttestOnChain{value: msg.value}(sgx_quote);
        // fail returns bytes(error_string)
        // success returns custom output type:
        // https://github.com/automata-network/automata-dcap-attestation/blob/b49a9f296a5e0cd8b1f076ec541b1239199cadd2/contracts/verifiers/V3QuoteVerifier.sol#L154
        require(success, string(output));
        processMessage(output, usdAmount, storageSlot2);
    }

    function processMessage(
        bytes memory output,
        uint256 usdAmount,   // storage slot 1
        uint256 storageSlot2 // storage slot 2
    ) internal {

        address depositor = address(uint160(storageSlot2));
        uint80 nonce = uint80(storageSlot2 >> 160);
        funcEnum func = funcEnum(uint8(storageSlot2 >> 240));
        nonceAssert(nonce);

        check_mrenclave(output);

        bytes memory quoteStorageSlot1 = new bytes(32);
        bytes memory quoteStorageSlot2 = new bytes(32);

        for (uint i = 0; i < 32; i++) {
            quoteStorageSlot1[i] = output[ENCLAVE_REPORT_OFFSET_OUTPUT + REPORT_DATA_OFFSET + i];
            quoteStorageSlot2[i] = output[ENCLAVE_REPORT_OFFSET_OUTPUT + REPORT_DATA_OFFSET + 32 + i];
        }


        require(bytes32(usdAmount) == bytes32(quoteStorageSlot1),    "storage slot 1 from input and from quote are not equal!");
        require(bytes32(storageSlot2) == bytes32(quoteStorageSlot2), "storage slot 2 from input and from quote are not equal!");

        messageDB.push(message(usdAmount, depositor, nonce, func));

        if (func == funcEnum.deposit) {
            syntheticStablecoin.mint(usdAmount);
        }
        if (func == funcEnum.withdraw) {
            syntheticStablecoin.burn(usdAmount);
        }

        // TODO emit event
        // TODO need to somehow track source chain using chain-id to call slashing for example

    }
}
