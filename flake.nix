{
  description = "A general purpose basic mathematical library for control theoretical computations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in {
        packages.slicot-reference = pkgs.callPackage ./default.nix {};
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = [
            pkgs.gnumake
            pkgs.gfortran13
            pkgs.blas
            pkgs.lapack
          ];
        };
      }
    );
}
