{lib}: let
  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
in {
  eachSystem = nixpkgs: callback:
    lib.genAttrs supportedSystems (
      system:
        callback nixpkgs.legacyPackages.${system}
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
}
