{lib, ...}:
with lib; {
  options.blackbox = {
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of packages to install in the shell";
    };

    env = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Environment variables to export";
    };

    shellHook = mkOption {
      type = types.lines;
      default = "";
      description = "Bash code to execute when entering the shell";
    };
  };
}
