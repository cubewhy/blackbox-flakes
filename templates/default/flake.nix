# vim:fileencoding=utf-8:foldmethod=marker
#: Tip: If you are using (n)vim, you can press zM to fold all the config blocks quickly (za to fold under cursor)
#: Tip: search keywords to start quickly
{
  #: Inputs {{{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blackbox.url = "github:cubewhy/blackbox-flakes";

    #: Do not forget to modify the `overlays` variable below after you added new overlays

    #: Uncomment if you need Rust
    # rust-overlay.url = "github:oxalica/rust-overlay";

    #: Uncomment if you need Golang
    # go-overlay.url = "github:purpleclay/nix-go";
  };
  #: inputs end }}}

  outputs = {
    self,
    blackbox,
    # rust-overlay,
    # go-overlay,
    nixpkgs,
    ...
  }: let
    #: Overlays {{{
    overlays = [
      # (import rust-overlay)
      # (import go-overlay)
    ];
    #: overlays end }}}
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

            #: Languages {{{

            #: Rust {{{
            blackbox.languages.rust = {
              enable = false;
              #: If your project has rust-toolchain.toml file
              #: Please modify this option with
              #: ./rust-toolchain.toml
              #: and comment other rust related options (expect `languages.rust.enable`)
              toolchainFile = null;

              #: channel: available values ["stable" "beta" "nightly" "nightly-<date>"]
              channel = "stable";
              components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" "rust-src"];
              #: any rust targets, like x86_64-pc-windows-gnu, leave blank to use platform default
              #: the blackbox flake contains the Windows cross-compile workaround (pthreads).
              #: But please notice that you may still need to tackle with 3rd party libraries like
              #: openssl
              targets = [
                # "x86_64-pc-windows-gnu"
              ];
            };
            #: rust end }}}

            #: Python {{{
            blackbox.languages.python = {
              enable = false;
              #: The python package to use
              package = pkgs.python3;
              #: The project dir
              directory = ".";
              #: The venv manager
              #: manager: available values ["pip" "uv" "poetry"]
              manager = "pip";
              #: This is samiliar to the npm thing, run install command on enter env
              #: If using pip -> `pip install -r requirements.txt`
              #: If using uv -> `uv sync` or the pip compat command `uv pip install -r`
              #: If using poetry -> `poetry install`
              #: The behavior depends on the manager option.
              autoInstall = false;
            };
            #: python end }}}

            #: C/C++ {{{
            blackbox.languages.c = {
              enable = false;
              #: compiler: available values ["gcc" "clang"]
              compiler = "gcc";
            };
            #: c/cpp end }}}

            #: Assembly {{{
            #: Enable this option will install nasm
            blackbox.languages.assembly.enable = false;
            #: asm end }}}

            #: Javascript/Typescript {{{
            #: tags: javascript, typescript, js, ts, nodejs, npm, pnpm, yarn
            blackbox.languages.javascript = {
              enable = false;
              #: Node.js package to use
              #: Note: use nodejs-slim if you don't need npm
              package = {
                nodejs = pkgs.nodejs;
                pnpm = pkgs.pnpm;
                yarn = pkgs.yarn;
                bun = pkgs.bun;
                deno = pkgs.deno;
              };
              #: manager: available values ["npm" "pnpm" "yarn" "bun" "deno"]
              #: If this set to bun or deno, nodejs will not be installed
              manager = "npm";
              #: Auto run `npm install` (or with other package managers) if package.json exist
              autoInstall = true;
              #: cwd to run `npm install`
              #: You may confused with the type str[] of the option
              #: In nix, you cannot pass . (current dir) to the path type, so string is a workaround for this.
              autoInstallDirs = [
                "."
              ];
            };
            #: javascript end }}}

            #: Java {{{
            blackbox.languages.java = {
              enable = false;
              package = pkgs.jdk;

              #: Java build tools
              maven = {
                enable = false;
                package = pkgs.maven;
              };

              gradle = {
                enable = false;
                package = pkgs.gradle;
              };
            };
            #: java end }}}

            #: Golang {{{
            blackbox.languages.go = {
              enable = false;
              version = "latest";
              #: enabled installTools option to install gopls, delve, golangci-lint, gotools
              installTools = false;
            };
            #: golang end }}}

            #: languages end }}}

            #: Libraries {{{
            blackbox.libraries = {
              #: OpenSSL {{{
              openssl.enable = false;
              #: openssl end }}}

              #: Cuda: {{{
              #: See https://nixos-cuda.org/ for enabling nix cuda cache
              cuda = {
                enable = false;
                #: version: e.g.  [11, 12, 13]
                version = "13";
              };
              #: cuda end }}}

              #: Graphics libs (X11, wayland, opengl, vulkan, nvidia) {{{
              #: Note: this feature doesn't contains cuda, if you need cuda, please enable blackbox.libraries.cuda.enable
              graphics.enable = false;
              #:}}}

              #: shared libraries {{{
              #: blackbox-flake will config LD_LIBRARY_PATH and LIBRARY_PATH for the following packages
              shared = with pkgs; [
                # alsa-lib
                # pipewire
                # libpulseaudio
              ];
              #: }}}
            };

            #: libraries end }}}

            #: Tools {{{
            blackbox.tools = {
              #: Pre-commit {{{
              pre-commit = {
                enable = false;
                #: Force run `pre-commit install` when enter shell
                #: This is not recommended, please don't enable it.
                runOnStart = false;
              };
              #: pre-commit end }}}
            };
            #: tools end }}}
          };
          #: config end }}}

          #: Custom options {{{

          #: mkShell builtin options are available
          # shellHook = ''
          # '';

          #: custom options end }}}
        };
      });
  };
}
