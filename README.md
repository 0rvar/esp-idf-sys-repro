# esp-idf-sys C++ bindings broken

Having trouble getting esp-idf-sys to generate bindings for the walter-modem component. The build chokes on C++ headers.

## What's happening

```
fatal error: 'bitset' file not found
```

The walter-modem component uses C++ and includes `<bitset>`, but bindgen can't find the C++ stdlib headers when processing `WalterModem.h`.

## Setup

Cargo.toml has:
```toml
[package.metadata.esp-idf-sys]
[[package.metadata.esp-idf-sys.extra_components]]
remote_component = { name = "dptechnics/walter-modem", version = "^1.4.0" }
bindings_module = "walter"
bindings_header = "walter.hpp"
```

walter.hpp just does:
```cpp
#include <WalterModem.h>
```

## What should work

The CONFIG defines work fine:
```rust
let apn_max_size = esp_idf_sys::CONFIG_WALTER_MODEM_APN_MAX_SIZE;
```

But the actual structs and functions don't get generated:
```rust
// This should exist but doesn't
let mut rsp: esp_idf_sys::walter::WalterModemRsp = mem::zeroed();
esp_idf_sys::walter::WalterModem_gnssGetUTCTime(&mut rsp, None, ptr::null_mut());
```

## The problem

WalterModem.h includes C++ headers but bindgen doesn't get the right compiler flags or include paths to find them.

## Reproducing

Just `cargo build` and watch it fail.