{lib}: let
  defaultSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
in {
  eachSystem = {
    nixpkgs,
    systems ? defaultSystems,
    overlays ? [],
    config ? {allowUnfree = true;},
  }: callback:
    lib.genAttrs systems (
      system: let
        pkgs = import nixpkgs {
          inherit system overlays config;
        };
      in
        callback pkgs
    );

  mkShell = {
    pkgs,
    config,
    ...
  } @ args: let
    # Evaluate the modules (merge user config with our internal modules)
    eval = lib.evalModules {
      modules = [
        # Import the base system schema
        ../modules/top-level.nix
        # Import all available feature modules (C, Rust, etc.)
        ../modules/default.nix
        # Import the user's specific configuration
        config
      ];
      # Pass 'pkgs' and 'lib' to all modules
      specialArgs = {inherit pkgs lib;};
    };

    bbConfig = eval.config.blackbox;

    userArgs = removeAttrs args ["pkgs" "config" "lib"];
  in
    pkgs.mkShell (
      userArgs
      // {
        packages = bbConfig.packages ++ (userArgs.packages or []);
        shellHook = bbConfig.shellHook + "\n" + (userArgs.shellHook or "");
        nativeBuildInputs = (userArgs.nativeBuildInputs or []) ++ (bbConfig.nativeBuildInputs or []);
      }
      // bbConfig.env
    );

  addToGitExclude = pattern: ''
    if [ -d .git ]; then
      exclude_file=".git/info/exclude"
      mkdir -p .git/info
      touch "$exclude_file"

      if ! grep -qF "${pattern}" "$exclude_file"; then
        echo "${pattern}" >> "$exclude_file"
      fi
    fi
  '';
}
