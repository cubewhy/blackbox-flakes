{...}: {
  imports = [
    # Languages
    ./languages/c.nix
    ./languages/rust.nix
    ./languages/javascript.nix
    ./languages/java.nix
    ./languages/go.nix
    ./languages/python.nix

    # Libraries
    ./libraries/openssl.nix
    ./libraries/cuda.nix

    # Tools
    ./tools/pre-commit.nix
  ];
}
