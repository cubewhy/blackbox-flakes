{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.rust;

  hasOverlay = builtins.hasAttr "rust-bin" pkgs;
  # TODO: support another windows target (win7)
  hasWindowsTarget = builtins.elem "x86_64-pc-windows-gnu" cfg.targets;

  toolchain =
    if hasOverlay
    then
      pkgs.rust-bin.${cfg.version}.latest.default.override {
        extensions = cfg.components;
        targets = cfg.targets;
      }
    else pkgs.rustc;

  mingwPkgs = pkgs.pkgsCross.mingwW64;
  mingwPthreads = mingwPkgs.windows.pthreads;
in {
  options.blackbox.languages.rust = {
    enable = mkEnableOption "Rust development environment";

    version = mkOption {
      type = types.str;
      default = "stable";
      description = "Rust toolchain version";
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

      blackbox.shellHook = mkIf (cfg.targets != [] && !hasOverlay) ''
        echo "⚠️  WARNING: Targets requested ${toString cfg.targets}, but 'rust-overlay' is missing."
        echo "⚠️  Please uncomment the overlay configuration in flake.nix to fix this."
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
        }
      ];
    })
  ]);
}
