{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.rust;

  hasOverlay = builtins.hasAttr "rust-bin" pkgs;

  toolchain =
    if hasOverlay
    then
      pkgs.rust-bin.${cfg.version}.latest.default.override {
        extensions = cfg.components;
        targets = cfg.targets;
      }
    else pkgs.rustc; # Fallback (targets won't work here)
in {
  options.blackbox.languages.rust = {
    enable = mkEnableOption "Rust development environment";

    version = mkOption {
      type = types.listOf types.str;
      default = "stable";
      description = "Rust toolchain version (requires rust-overlay for advanced features)";
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["wasm32-unknown-unknown" "x86_64-pc-windows-gnu"];
      description = "List of cross-compilation targets to install (requires rust-overlay)";
    };

    components = mkOption {
      type = types.listOf types.str;
      default = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
      example = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
      description = "List of Rust components to install (requires rust-overlay)";
    };
  };

  config = mkIf cfg.enable {
    # Base Packages
    blackbox.packages =
      [
        # The Rust Toolchain (Compiler + Cargo)
        (
          if hasOverlay
          then toolchain
          else pkgs.cargo
        )

        # Build Tools
        pkgs.gnumake
      ]
      # Add Standard Rust tools if no overlay (if overlay exists, they are in toolchain)
      ++ optionals (!hasOverlay) [
        pkgs.rustc
        pkgs.rust-analyzer
        pkgs.rustfmt
        pkgs.clippy
      ];

    # Environment Variables
    blackbox.env = mkMerge [
      {
        RUST_BACKTRACE = "1";
        # If overlay is used, source path is managed by the toolchain wrapper usually,
        # but we can fallback to the standard path if needed.
        RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
      }

      # OpenSSL Configuration
    ];

    # Warn user if they try to use targets without overlay
    blackbox.shellHook = mkIf (cfg.targets != [] && !hasOverlay) ''
      echo "⚠️  WARNING: You requested Rust targets ${toString cfg.targets}, but 'pkgs.rust-bin' was not found."
      echo "   Please add 'oxalica/rust-overlay' to your flake inputs and apply it to pkgs."
    '';
  };
}
