// prototype pseudocode

#[no_mangle]
pub unsafe extern "C" fn trusted_execution(chain_id, depositor, native_token_amount)
        -> SgxStatus { //triggered after event "deposited" is emited on the source chain

    (chain_id, depositor, stablecoins_amount) = deposited(chain_id, depositor, native_token_amount);

    tracing::info!("chain_id:\t{:?}", chain_id);
    tracing::info!("depositor:\t{:?}", depositor);
    tracing::info!("stablecoins_amount:\t{:?}", stablecoins_amount);

    print_vec_of_strings(chain_id, "chain_id.bin");
    print_vec_of_strings(depositor, "depositor.bin");
    print_vec_of_strings(stablecoins_amount, "stablecoins_amount.bin");

    let mut all_hashes = Vec::new();

    let chain_id_hash = abi_encode_and_keccak(InputValue::todo(chain_id.clone()));
    let depositor_hash = abi_encode_and_keccak(InputValue::todo(*depositor));
    let stablecoins_amount_hash = abi_encode_and_keccak(InputValue::todo(*stablecoins_amount));

    // debug info
    tracing::debug!("chain_id_hash:           0x{}", hex::encode(chain_id_hash));
    tracing::debug!("depositor_hash:          0x{}", hex::encode(depositor_hash));
    tracing::debug!("stablecoins_amount_hash: 0x{}", hex::encode(stablecoins_amount_hash));
    tracing::debug!("----------------------------------------------");

    all_hashes.extend_from_slice(&chain_id_hash);
    all_hashes.extend_from_slice(&depositor_hash);
    all_hashes.extend_from_slice(&stablecoins_amount_hash);

    let mut final_hasher = Keccak::v256();
    final_hasher.update(&all_hashes);
    let mut final_hash = [0u8; 32];
    final_hasher.finalize(&mut final_hash);

    tracing::info!("Final hash of all items: 0x{}", hex::encode(final_hash));

    // The following code is used to generate an attestation report
    // Must be run on sgx-supported machine
    let mut data: [u8; 64] = [
        // recognizable pattern can easily be seen in xxd
        0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 0u8, 1u8,
        2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 0u8, 1u8, 2u8, 3u8,
        4u8, 5u8, 6u8, 7u8, 0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 0u8, 1u8, 2u8, 3u8, 4u8, 5u8,
        6u8, 7u8, 0u8, 1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8,
    ];

    data[..32].copy_from_slice(&final_hash);
    // TODO could add hashed request is some form, like pairs list, it is from file, not trusted
    // data[32..].copy_from_slice(&hashed_request);

    let attestation = automata_sgx_sdk::dcap::dcap_quote(data);
    let result = match attestation {
        Ok(attestation) => {
            tracing::info!("DCAP attestation:\n0x{}", hex::encode(&attestation));

            let filename_bytes = create_buffer_from_stirng("sgx_quote.bin".to_string());
            ocall_write_to_file(
                attestation.as_ptr(),
                attestation.len(),
                filename_bytes.as_ptr(),
                filename_bytes.len(),
            );

            SgxStatus::Success
        }
        Err(e) => {
            tracing::error!("Generating attestation failed: {:?}", e);
            SgxStatus::Unexpected
        }
    };
    tracing::debug!("=============== End of trusted execution =================");

    result
}


fn deposited(chain_id: u64, depositor: &str, native_token_amount: u64) -> (u64, String, u64) {
    let mut token_mapping: HashMap<u64, &str> = HashMap::new();
    token_mapping.insert(43114, "AVAX");
    token_mapping.insert(  146, "SONIC");
    token_mapping.insert(42161, "ETH");
    token_mapping.insert(   10, "ETH");
    token_mapping.insert( 8453, "ETH");
    token_mapping.insert(65536, "ATA");
    token_mapping.insert(80094, "BERA");

    let native_token = token_mapping.get(&chain_id)
        .ok_or("Token name is not found for chain id")?;
    let token_symbol = format!("{}USDT", native_token);

    let url = format!("https://data-api.binance.vision/api/v3/ticker/price?symbol={}", token_symbol);
    price = http_request(url);

    let stablecoins_amount = price * native_token_amount;

    output = (chain_id, depositor, stablecoins_amount);
    return output;
}
