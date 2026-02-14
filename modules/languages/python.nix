{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.python;

  venvName = ".venv";
  venvPath = "${cfg.directory}/${venvName}";
  projectRoot = cfg.directory;
in {
  options.blackbox.languages.python = {
    enable = mkEnableOption "Python development environment";

    package = mkOption {
      type = types.package;
      default = pkgs.python3;
      description = "The Python interpreter package.";
    };

    directory = mkOption {
      type = types.str;
      default = ".";
      description = "The Python project's root directory (relative to flake root).";
    };

    manager = mkOption {
      type = types.enum ["pip" "uv" "poetry"];
      default = "pip";
      description = "Package manager to use. 'pip' uses requirements.txt, 'uv' uses uv.lock, 'poetry' uses poetry.lock.";
    };

    autoInstall = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically install dependencies (pip install / uv sync / poetry install) on shell entry.";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [cfg.package]
      ++ optionals (cfg.manager == "uv") [pkgs.uv]
      ++ optionals (cfg.manager == "poetry") [pkgs.poetry];

    blackbox.libraries.shared = [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.glib
    ];

    blackbox.env = {
      PYTHONUNBUFFERED = "1";

      VIRTUAL_ENV = "$PWD/${venvPath}";

      POETRY_VIRTUALENVS_IN_PROJECT = "true";
      POETRY_VIRTUALENVS_PATH = "$PWD/${projectRoot}";
    };

    blackbox.shellHook = ''
      mkdir -p "${projectRoot}"

      if [ -d .git ]; then
        exclude_file=".git/info/exclude"
        mkdir -p .git/info
        if ! grep -qF "${venvPath}/" "$exclude_file"; then
           echo "${venvPath}/" >> "$exclude_file"
        fi
      fi

      case "${cfg.manager}" in
        "pip")
          if [ ! -d "${venvPath}" ]; then
            echo "[blackbox] Creating venv (pip)..."
            (cd "${projectRoot}" && ${cfg.package}/bin/python -m venv ".venv")
          fi

          source "$PWD/${venvPath}/bin/activate"

          ${optionalString cfg.autoInstall ''
        if [ -f "${projectRoot}/requirements.txt" ]; then
          echo "[blackbox] Found requirements.txt, running pip install..."
          (cd "${projectRoot}" && pip install -r requirements.txt)
        fi
      ''}
          ;;

        "uv")
          if [ ! -d "${venvPath}" ]; then
            echo "[blackbox] Creating venv (uv)..."
            (cd "${projectRoot}" && uv venv .venv --python "${cfg.package}/bin/python")
          fi

          source "$PWD/${venvPath}/bin/activate"

          ${optionalString cfg.autoInstall ''
        if [ -f "${projectRoot}/uv.lock" ] || [ -f "${projectRoot}/pyproject.toml" ]; then
          echo "[blackbox] Found project config, running 'uv sync'..."
          (cd "${projectRoot}" && uv sync)
        elif [ -f "${projectRoot}/requirements.txt" ]; then
          echo "[blackbox] Found requirements.txt, running 'uv pip install'..."
          (cd "${projectRoot}" && uv pip install -r requirements.txt)
        fi
      ''}
          ;;

        "poetry")
          ${optionalString cfg.autoInstall ''
        if [ -f "${projectRoot}/poetry.lock" ] || [ -f "${projectRoot}/pyproject.toml" ]; then
          echo "[blackbox] Running poetry install..."
          (cd "${projectRoot}" && poetry install)
        fi
      ''}

          if [ ! -d "${venvPath}" ]; then
             echo "[blackbox] Initializing poetry env..."
             (cd "${projectRoot}" && poetry env use "${cfg.package}/bin/python")
          fi

          source "$PWD/${venvPath}/bin/activate"
          ;;
      esac
    '';
  };
}
