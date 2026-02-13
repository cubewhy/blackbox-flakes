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

  createCmd =
    if cfg.manager == "uv"
    then "uv venv ${venvPath} --python ${cfg.package}/bin/python"
    else "${cfg.package}/bin/python -m venv ${venvPath}";
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
      type = types.enum ["venv" "uv"];
      default = "uv";
      description = "Tool to create the virtual environment.";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [
        cfg.package
      ]
      ++ optionals (cfg.manager == "uv") [
        pkgs.uv
      ];

    blackbox.env = {
      LD_LIBRARY_PATH = "${lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
        pkgs.glib
      ]}:$LD_LIBRARY_PATH";

      PYTHONUNBUFFERED = "1";

      VIRTUAL_ENV = "$PWD/${venvPath}";
    };

    blackbox.shellHook = ''
      if [ ! -d "${cfg.directory}" ]; then
         mkdir -p "${cfg.directory}"
      fi

      if [ -d .git ]; then
        exclude_file=".git/info/exclude"
        mkdir -p .git/info
        if ! grep -qF "${venvPath}/" "$exclude_file"; then
           echo "${venvPath}/" >> "$exclude_file"
           echo "[blackbox] Added '${venvPath}/' to .git/info/exclude"
        fi
      fi

      # Create Venv if missing
      if [ ! -d "${venvPath}" ]; then
        echo "[blackbox] Creating virtual environment in '${venvPath}' via ${cfg.manager}..."
        ${createCmd}
      fi

      # Activate Venv
      if [ -f "${venvPath}/bin/activate" ]; then
         source "${venvPath}/bin/activate"
      fi
    '';
  };
}
