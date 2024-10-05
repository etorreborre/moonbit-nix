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
      moonbit = pkgs.callPackage ./pkgs/moonbit.nix { };
      ocaml_overlay = final: prev: {
        ocamlPackages = prev.ocaml-ng.ocamlPackages_5_2;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ocaml_overlay ];
      };
    in
    {
      packages.${system} = rec {
        inherit moonbit;
        default = moonbit;
      };

      devShells.${system} = rec {
        default = moonbit-dev;
        moonbit-dev = pkgs.mkShell {
          packages = [ moonbit ];
        };
        rescript-compiler-dev = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.ocamlPackages.ocaml ];
          buildInputs = with pkgs.ocamlPackages; [
            dune_3
            ocamlformat_0_26_2
            cppo
            ounit2
            js_of_ocaml

            # node
            pkgs.ninja
            pkgs.nodejs
            pkgs.cargo
          ];
        };
      };
    };
}
