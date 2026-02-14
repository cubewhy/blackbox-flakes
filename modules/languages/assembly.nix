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
  };

  config = mkIf cfg.enable {
    blackbox.packages = [
      pkgs.nasm
    ];
  };
}
