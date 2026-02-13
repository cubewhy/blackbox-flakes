{...}: {
  imports = [
    # Languages
    ./languages/c.nix
    ./languages/rust.nix

    # Libraries
    ./libraries/openssl.nix
    ./libraries/cuda.nix
  ];
}
