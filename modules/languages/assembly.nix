{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.assembly;
in {
  options.blackbox.languages.assembly = {
    enable = mkEnableOption "Assembly development environment";

    package = mkOption {
      type = types.package;
      default = pkgs.nasm;
      defaultText = "pkgs.nasm";
      description = "The assembler package to use";
    };

    linker = {
      enable = mkEnableOption "Linker";
      package = mkOption {
        type = types.package;
        default = pkgs.gcc;
        defaultText = "pkgs.gcc";
        description = "The linker package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [cfg.package]
      ++ optional cfg.linker.enable cfg.linker.package;
  };
}
