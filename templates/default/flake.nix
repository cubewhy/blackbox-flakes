{
  inputs.blackbox.url = "github:cubewhy/blackbox-flakes";

  outputs = {
    self,
    blackbox,
    nixpkgs,
  }: {
    devShells = blackbox.lib.eachSystem nixpkgs (pkgs: {
      default = blackbox.lib.mkShell {
        inherit pkgs;
        config = {
          # Note: change the options there
          # You can delete unused options

          # Rust
          blackbox.languages.rust = {
            enable = false;
            version = "stable"; # available values ["stable" "nightly"]
            components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
            targets = []; # any rust targets, like x86_64-pc-windows-gnu, leave blank to use platform default
          };

          # C/C++
          blackbox.languages.c = {
            enable = false;
            compiler = "gcc"; # available values ["gcc" "clang"]
          };

          # Libraries
          blackbox.libraries = {
            openssl.enable = false;
          };
        };
      };
    });
  };
}
