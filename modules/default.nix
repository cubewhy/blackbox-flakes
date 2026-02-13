{...}: {
  imports = [
    # Languages
    ./languages/c.nix
    ./languages/rust.nix
    ./languages/javascript.nix

    # Libraries
    ./libraries/openssl.nix
    ./libraries/cuda.nix
  ];
}
