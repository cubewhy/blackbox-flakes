{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.tools.pre-commit;
in {
  options.blackbox.tools.pre-commit = {
    enable = mkEnableOption "pre-commit framework (relies on .pre-commit-config.yaml)";

    runOnStart = mkOption {
      type = types.bool;
      default = false;
      description = "Run 'pre-commit run --all-files' immediately when entering the shell";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages = [pkgs.pre-commit];

    blackbox.shellHook = ''
      if [ -f .pre-commit-config.yaml ]; then
        if [ -d .git ] && [ ! -f .git/hooks/pre-commit ]; then
           echo "[blackbox] Detected .pre-commit-config.yaml. Installing git hooks..."
           pre-commit install
        fi

        ${optionalString cfg.runOnStart ''
        echo "[blackbox] Running pre-commit checks on all files..."
        pre-commit run --all-files
      ''}
      else
        echo "⚠️ [blackbox] No .pre-commit-config.yaml found in your project, but you have pre-commit enabled."
      fi
    '';
  };
}
