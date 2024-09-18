{
  description = "moonbit nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      moonbit = pkgs.callPackage ./pkgs/moonbit.nix { };
    in
    {
      packages.${system} = rec {
        inherit moonbit;
        default = moonbit;
      };

      devShells.${system} = {
        default = pkgs.mkShell rec {
          packages = [ moonbit ];
        };
      };
    };
}
