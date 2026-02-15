{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.rust;

  hasOverlay = builtins.hasAttr "rust-bin" pkgs;

  tomlTargets =
    if cfg.toolchainFile != null && builtins.pathExists cfg.toolchainFile
    then let
      toml = builtins.fromTOML (builtins.readFile cfg.toolchainFile);
    in
      # Handle [toolchain] table format
      toml.toolchain.targets or []
    else [];

  effectiveTargets = cfg.targets ++ tomlTargets;

  hasWindowsTarget = builtins.any (t: (builtins.match ".*windows.*" t) != null) effectiveTargets;

  toolchain =
    if hasOverlay
    then
      if cfg.toolchainFile != null
      then
        # Use rust-toolchain.toml
        pkgs.rust-bin.fromRustupToolchainFile cfg.toolchainFile
      else
        # Use explicit config options
        pkgs.rust-bin.${cfg.channel}.latest.default.override {
          extensions = cfg.components;
          targets = cfg.targets;
        }
    else
      # Fallback: System Rust
      pkgs.rustc;

  mingwPkgs = pkgs.pkgsCross.mingwW64;
  mingwPthreads = mingwPkgs.windows.pthreads;
in {
  options.blackbox.languages.rust = {
    enable = mkEnableOption "Rust development environment";

    toolchainFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = ./rust-toolchain.toml;
      description = "Path to rust-toolchain.toml. Overrides 'channel', 'targets' (for installation), and 'components'.";
    };

    channel = mkOption {
      type = types.str;
      default = "stable";
      description = "Rust toolchain channel";
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["x86_64-pc-windows-gnu"];
      description = "List of cross-compilation targets";
    };

    components = mkOption {
      type = types.listOf types.str;
      default = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
      description = "Rust components";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      blackbox.packages =
        [
          (
            if hasOverlay
            then toolchain
            else pkgs.cargo
          )
          pkgs.gnumake
        ]
        ++ optionals (!hasOverlay) [
          pkgs.rustc
          pkgs.rust-analyzer
          pkgs.rustfmt
          pkgs.clippy
        ];

      blackbox.env = {
        RUST_BACKTRACE = "1";
        RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
      };

      blackbox.shellHook = mkIf ((cfg.targets != [] || cfg.toolchainFile != null) && !hasOverlay) ''
        echo "⚠️ [blackbox] Overlay 'rust-overlay' is missing."
        echo "⚠️ [blackbox] Please uncomment the overlay configuration in flake.nix to fix this."
      '';
    }

    # Windows Cross-Compilation Configuration
    (mkIf hasWindowsTarget {
      blackbox.packages = [mingwPkgs.stdenv.cc];

      blackbox.env = mkMerge [
        {
          CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER = "${mingwPkgs.stdenv.cc}/bin/x86_64-w64-mingw32-gcc";

          CFLAGS_x86_64_pc_windows_gnu = "-I${mingwPthreads}/include";
          CXXFLAGS_x86_64_pc_windows_gnu = "-I${mingwPthreads}/include";
          # TODO: add rustflags for other windows targets
          CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS = ''
            -L native=${mingwPthreads}/lib
          '';
        }
      ];
    })
  ]);
}
