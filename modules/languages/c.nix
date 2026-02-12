{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.c;
in {
  options.blackbox.languages.c = {
    enable = mkEnableOption "C/C++ development environment";

    compiler = mkOption {
      type = types.enum ["gcc" "clang"];
      default = "gcc";
      description = "Compiler to use";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages = [
      pkgs.gnumake
      pkgs.cmake
      pkgs.gdb
      (
        if cfg.compiler == "clang"
        then pkgs.clang
        else pkgs.gcc
      )
    ];

    blackbox.env = {
      CC =
        if cfg.compiler == "clang"
        then "clang"
        else "gcc";
      CXX =
        if cfg.compiler == "clang"
        then "clang++"
        else "g++";
    };
  };
}
