{
  description = "blackbox-flakes: Extra fast devenv replacement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    lib = import ./lib {inherit (nixpkgs) lib;};

    # A template to help users get started quickly
    templates.default = {
      path = ./templates/default;
      description = "Default blackbox template";
    };
  };
}
