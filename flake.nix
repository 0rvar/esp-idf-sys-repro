{
  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      # Boilerplate function for generating attributes for all systems
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            (function (
              import nixpkgs {
                inherit system;
              }
            ))
              system
          );
    in
    {
      packages = forAllSystems (
        pkgs: system:
        let
          tools = with pkgs; [
            bun
            espup
            espflash
            esptool
            ldproxy
          ];
          inputs = with pkgs; [
            libiconv
            SDL2
            curlMinimal
          ];
          optionalInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Needed for libgit2 when doing `cargo install cargo-espflash`
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];
        in
        {
          default = pkgs.mkShell {
            buildInputs = tools ++ inputs ++ optionalInputs;
            shellHook = ''
              export LIBCLANG_PATH="$HOME/.espup/esp-clang"
              export PATH="/Users/orvar/.rustup/toolchains/esp/xtensa-esp-elf/esp-14.2.0_20240906/xtensa-esp-elf/bin:$PATH" 

              # Remove Python from Nix environment to let ESP-IDF manage its own
              export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v python | tr '\n' ':' | sed 's/:$//')
              unset PYTHONPATH
              unset PYTHON
              unset PYTHONHOME
            '';
          };
        }
      );
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  description = "Devshell with all the dependencies needed to develop and build the project";
}
