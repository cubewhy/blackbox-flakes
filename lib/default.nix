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
  }: let
    # 1. Evaluate the modules (merge user config with our internal modules)
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

    # 2. Extract the final configuration
    finalConfig = eval.config;
  in
    # 3. Generate the actual shell
    pkgs.mkShell {
      packages = finalConfig.blackbox.packages;
      shellHook = finalConfig.blackbox.shellHook;

      # Automatically export environment variables defined in modules
      # iterating over the attribute set
    }
    // finalConfig.blackbox.env;
}
