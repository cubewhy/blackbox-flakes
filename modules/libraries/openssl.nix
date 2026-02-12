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
    enable = mkEnableOption "OpenSSL development library (includes pkg-config setup)";
  };

  config = mkIf cfg.enable {
    blackbox.packages = [
      pkgs.openssl
      pkgs.pkg-config
    ];

    blackbox.env = {
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";

      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

      OPENSSL_NO_VENDOR = "1";
    };
  };
}
