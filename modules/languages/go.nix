{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.languages.go;

  pkgName =
    if cfg.version == "latest"
    then
      (
        if builtins.hasAttr "go_latest" pkgs
        then "go_latest"
        else "go"
      )
    else "go_" + builtins.replaceStrings ["."] ["_"] cfg.version;

  goPkg =
    if builtins.hasAttr pkgName pkgs
    then pkgs.${pkgName}
    else pkgs.go;
in {
  options.blackbox.languages.go = {
    enable = mkEnableOption "Go (Golang) environment";

    version = mkOption {
      type = types.str;
      default = "latest";
      example = "1.22";
      description = "Go version. Maps to pkgs.go_<version>. Use 'latest' for pkgs.go_latest (requires overlay) or pkgs.go.";
    };

    installTools = mkOption {
      type = types.bool;
      default = false;
      description = "Install common tools: gopls, delve (debugger), golangci-lint, gotools";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages =
      [
        goPkg
      ]
      ++ optionals cfg.installTools [
        pkgs.gopls # LSP
        pkgs.delve # Debugger (dlv)
        pkgs.golangci-lint # Linter
        pkgs.gotools # goimports, godoc, etc.
      ];

    blackbox.env = {
      GOPATH = "$PWD/.go";
      GOBIN = "$PWD/.go/bin";

      PATH = "$PWD/.go/bin:$PATH";
    };

    blackbox.shellHook = ''
      ${addToGitExclude "/.go/"}

      ${optionalString (cfg.version != "latest" && !builtins.hasAttr pkgName pkgs) ''
        echo "⚠️ [blackbox] Requested version '${cfg.version}' (${pkgName}) not found in pkgs."
        echo "   [blackbox] Falling back to system default: $(go version)"
        echo "   [blackbox] Tip: Use 'purpleclay/go-overlay' for specific versions."
      ''}
    '';
  };
}
