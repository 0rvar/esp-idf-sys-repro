use std::{mem, ptr};

fn main() {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    // This reference works - apparently some defines make it into the
    // generated bindings - but only the "CONFIG_" prefixed ones.
    // However, they don't go into the "walter" module as
    // configured in Cargo.toml.
    let apn_max_size = esp_idf_sys::CONFIG_WALTER_MODEM_APN_MAX_SIZE;

    // However, the real meat of the library is not included in
    // the bindings at all:
    unsafe {
        // Not in the root as above
        let mut rsp: esp_idf_sys::WalterModemRsp = mem::zeroed();
        esp_idf_sys::WalterModem_gnssGetUTCTime(&mut rsp, None, ptr::null_mut());
    }
    unsafe {
        // Not in the configured module either
        let mut rsp: esp_idf_sys::walter::WalterModemRsp = mem::zeroed();
        esp_idf_sys::walter::WalterModem_gnssGetUTCTime(&mut rsp, None, ptr::null_mut());
    }
}
