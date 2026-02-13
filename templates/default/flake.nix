# vim:fileencoding=utf-8:foldmethod=marker
#: Tip: If you are using (n)vim, you can press zM to fold all the config blocks quickly (za to fold under cursor)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blackbox.url = "github:cubewhy/blackbox-flakes";

    #: Do not forget to modify the `overlays` variable below after you added new overlays

    #: Uncomment if you need Rust
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
            #: Note: change the options there
            #: You can delete unused options

            #: Rust {{{
            blackbox.languages.rust = {
              enable = false;
              #: version: available values ["stable" "beta" "nightly" "nightly-<date>"]
              version = "stable";
              components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
              #: any rust targets, like x86_64-pc-windows-gnu, leave blank to use platform default
              #: the blackbox flake contains the Windows cross-compile workaround (pthreads).
              #: But please notice that you may still need to tackle with 3rd party libraries like
              #: openssl
              targets = [
                # "x86_64-pc-windows-gnu"
              ];
            };
            #: }}}

            #: C/C++ {{{
            blackbox.languages.c = {
              enable = false;
              #: compiler: available values ["gcc" "clang"]
              compiler = "gcc";
            };
            #: }}}

            #: Javascript/Typescript {{{
            blackbox.languages.javascript = {
              enable = true;
              #: Node.js package to use
              package = pkgs.nodejs;
              #: manager: available values ["npm" "pnpm" "yarn"]
              manager = "npm";
              #: Auto run `npm install` (or with other package managers) if package.json exist
              autoInstall = true;
            };
            #: }}}

            #: Libraries {{{
            blackbox.libraries = {
              #: OpenSSL {{{
              openssl.enable = false;
              #: }}}

              #: Cuda: {{{
              #: See https://nixos-cuda.org/ for enabling nix cuda cache
              cuda = {
                enable = false;
                #: version: e.g.  [11, 12, 13]
                version = "13";
                #: Enable this to install nvidia_x11 package
                withDrivers = true;
              };
              #: }}}
            };
            #: }}}

            #: Tools {{{
            blackbox.tools.pre-commit = {
              enable = false;
              #: Force run `pre-commit install` when enter shell
              #: This is not recommended, please don't enable it.
              runOnStart = false;
            };
            #: }}}
          };
          #: }}}

          #: mkShell builtin options are available
          # shellHook = ''
          # '';
        };
      });
  };
}
