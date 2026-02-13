{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.javascript;
  installCmd =
    {
      npm = "npm install";
      yarn = "yarn";
      pnpm = "pnpm install";
    }.${
      cfg.manager
    };
in {
  options.blackbox.languages.javascript = {
    enable = mkEnableOption "JavaScript / Node.js environment";

    package = mkOption {
      type = types.package;
      default = pkgs.nodejs;
      defaultText = "pkgs.nodejs";
      description = "Node.js package to use (e.g., pkgs.nodejs_22, pkgs.nodejs-slim)";
    };

    manager = mkOption {
      type = types.enum ["npm" "yarn" "pnpm"];
      default = "npm";
      description = "Package manager to use";
    };

    autoInstall = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically install dependencies if node_modules is missing";
    };

    # TODO: bun/deno
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [
        cfg.package
      ]
      ++ optionals (cfg.manager == "yarn") [pkgs.yarn]
      ++ optionals (cfg.manager == "pnpm") [pkgs.pnpm];

    blackbox.env = {
      PATH = "$PWD/node_modules/.bin:$PATH";
    };

    blackbox.shellHook = mkIf cfg.autoInstall ''
      if [ -f "package.json" ]; then
        if [ ! -d "node_modules" ]; then
          echo "[blackbox] 'node_modules' missing."
          echo "[blackbox] Running: ${installCmd}..."
          ${installCmd}
        fi
      fi
    '';
  };
}
