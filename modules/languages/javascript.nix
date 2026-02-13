{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.javascript;
  installCommands = {
    npm = "npm install";
    yarn = "yarn";
    pnpm = "pnpm install";
    bun = "bun install";
    deno = "deno install";
  };

  installCmd = installCommands.${cfg.manager};

  mkInstallScript = path: ''
    (
      if [ -d "${path}" ]; then
        cd "${path}"

        if { [ -f "package.json" ] || [ -f "deno.json" ] || [ -f "deno.jsonc" ]; } && [ ! -d "node_modules" ]; then
          echo "[blackbox] Missing dependencies in ${path}. Running ${installCmd}..."
          ${installCmd}
        fi
      fi
    )
  '';
in {
  options.blackbox.languages.javascript = {
    enable = mkEnableOption "JavaScript environment";

    package = {
      nodejs = mkOption {
        type = types.package;
        default = pkgs.nodejs;
        defaultText = "pkgs.nodejs";
        description = "Node.js package to use (e.g., pkgs.nodejs_22, pkgs.nodejs-slim)";
      };

      pnpm = mkOption {
        type = types.package;
        default = pkgs.pnpm;
        defaultText = "pkgs.pnpm";
        description = "PNPM package to use";
      };

      yarn = mkOption {
        type = types.package;
        default = pkgs.yarn;
        defaultText = "pkgs.yarn";
        description = "Yarn package to use";
      };

      bun = mkOption {
        type = types.package;
        default = pkgs.bun;
        defaultText = "pkgs.bun";
        description = "Bun package to use";
      };

      deno = mkOption {
        type = types.package;
        default = pkgs.deno;
        defaultText = "pkgs.deno";
        description = "Deno package to use";
      };
    };

    manager = mkOption {
      type = types.enum ["npm" "yarn" "pnpm" "bun" "deno"];
      default = "npm";
      description = "Package manager to use";
    };

    autoInstallDirs = mkOption {
      type = types.listOf types.str;
      default = ["."];
      example = ["." "./dashboard" "./api"];
      description = "List of directories to check for package.json and install dependencies.";
    };

    autoInstall = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically install dependencies if node_modules is missing";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      (
        if cfg.manager == "bun"
        then [cfg.package.bun]
        else if cfg.manager == "deno"
        then [cfg.package.deno]
        else [cfg.package.nodejs]
      )
      ++ optionals (cfg.manager == "yarn") [cfg.package.yarn]
      ++ optionals (cfg.manager == "pnpm") [cfg.package.pnpm];

    blackbox.env =
      {PATH = "$PWD/node_modules/.bin:$PATH";}
      // optionalAttrs (cfg.manager == "deno") {
        DENO_INSTALL_ROOT = "$HOME/.deno";
      };

    blackbox.shellHook = mkIf cfg.autoInstall (
      concatStringsSep "\n" (map mkInstallScript cfg.autoInstallDirs)
    );
  };
}
