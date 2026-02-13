{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.libraries.openssl;
in {
  options.blackbox.libraries.openssl = {
    enable = mkEnableOption "OpenSSL library";
  };

  config = mkIf cfg.enable {
    blackbox.packages = [
      pkgs.pkg-config
      pkgs.openssl
      pkgs.openssl.dev
    ];

    blackbox.env = {
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";

      OPENSSL_NO_VENDOR = "1";
    };
  };
}
