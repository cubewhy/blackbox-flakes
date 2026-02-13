# vim:fileencoding=utf-8:foldmethod=marker
# Tip: If you are using (n)vim, you can press zM to fold all the config blocks quickly (za to fold under cursor)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blackbox.url = "github:cubewhy/blackbox-flakes";

    # Do not forget to modify the `overlays` variable below after you added new overlays

    # Uncomment if you need Rust
    # rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    blackbox,
    # rust-overlay,
    nixpkgs,
    ...
  }: let
    overlays = [
      # (import rust-overlay)
    ];
  in {
    devShells =
      blackbox.lib.eachSystem {
        inherit nixpkgs overlays;
      } (pkgs: {
        default = blackbox.lib.mkShell {
          inherit pkgs;
          #: Config {{{
          config = {
            # Note: change the options there
            # You can delete unused options

            #: Rust {{{
            blackbox.languages.rust = {
              enable = false;
              version = "stable"; # available values ["stable" "beta" "nightly" "nightly-<date>"]
              components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
              # any rust targets, like x86_64-pc-windows-gnu, leave blank to use platform default
              # the blackbox flake contains the Windows cross-compile workaround (pthreads).
              # But please notice that you may still need to tackle with 3rd party libraries like
              # openssl
              targets = [
                # "x86_64-pc-windows-gnu"
              ];
            };
            #: }}}

            #: C/C++ {{{
            blackbox.languages.c = {
              enable = false;
              compiler = "gcc"; # available values ["gcc" "clang"]
            };
            #: }}}

            #: Libraries {{{
            blackbox.libraries = {
              #: OpenSSL {{{
              openssl.enable = false;
              #: }}}

              #: Cuda: {{{
              cuda = {
                enable = false;
                version = "13"; # [11, 12, 13]
                # Enable this to install nvidia_x11 package
                withDrivers = true;
              };
              #: }}}
            };
            #: }}}
          };
          #: }}}

          # mkShell builtin options are available
          # shellHook = ''
          # '';
        };
      });
  };
}
