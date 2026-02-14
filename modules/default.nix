{...}: {
  imports = [
    ./core/libraries.nix

    # Languages
    ./languages/assembly.nix
    ./languages/c.nix
    ./languages/rust.nix
    ./languages/javascript.nix
    ./languages/java.nix
    ./languages/go.nix
    ./languages/python.nix

    # Libraries
    ./libraries/openssl.nix
    ./libraries/cuda.nix
    ./libraries/graphics.nix

    # Tools
    ./tools/pre-commit.nix
  ];
}
