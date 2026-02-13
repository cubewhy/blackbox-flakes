{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.java;
in {
  options.blackbox.languages.java = {
    enable = mkEnableOption "Java development environment";

    package = mkOption {
      type = types.package;
      default = pkgs.jdk;
      defaultText = "pkgs.jdk (usually the latest LTS)";
      description = "The JDK package to use (e.g. pkgs.jdk17, pkgs.jdk8, pkgs.graalvm-ce)";
    };

    maven = {
      enable = mkEnableOption "Maven build tool";
      package = mkOption {
        type = types.package;
        default = pkgs.maven;
        defaultText = "pkgs.maven";
        description = "The Maven package to use";
      };
    };

    gradle = {
      enable = mkEnableOption "Gradle build tool";
      package = mkOption {
        type = types.package;
        default = pkgs.gradle;
        defaultText = "pkgs.gradle";
        description = "The Gradle package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [
        cfg.package
      ]
      ++ optional cfg.maven.enable cfg.maven.package
      ++ optional cfg.gradle.enable cfg.gradle.package;

    blackbox.env = {
      JAVA_HOME = "${cfg.package.home}";
      JDK_HOME = "${cfg.package.home}";
    };

    blackbox.shellHook = ''
      echo "[blackbox] JAVA_HOME: $JAVA_HOME"
    '';
  };
}
