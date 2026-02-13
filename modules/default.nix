{...}: {
  imports = [
    # Languages
    ./languages/c.nix
    ./languages/rust.nix
    ./languages/javascript.nix
    ./languages/java.nix

    # Libraries
    ./libraries/openssl.nix
    ./libraries/cuda.nix

    # Tools
    ./tools/pre-commit.nix
  ];
}
