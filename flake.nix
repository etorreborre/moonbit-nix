{
  description = "moonbit nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";

    ocaml-overlay.url = "github:nix-ocaml/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ocaml-overlay,
    }:
    let
      system = "x86_64-linux";
      moonbit = pkgs.callPackage ./pkgs/moonbit.nix { };
      ocaml_overlay = final: prev: {
        ocamlPackages = prev.ocaml-ng.ocamlPackages_5_2;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ocaml_overlay
          ocaml-overlay.overlays.default
        ];
      };
      opam-null = pkgs.writeShellScriptBin "opam" ''
        if [ "$1" = "exec" ] && [ "$2" = "--" ]; then
          $@
        else 
          echo "invalid opam command"
          exit 1
        fi
      '';
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
          packages = with pkgs.ocamlPackages; [
            opam-null
            dune_3
            ocamlformat_0_26_2
            cppo
            ounit2
            js_of_ocaml
            reanalyze

            # node
            pkgs.ninja
            pkgs.nodejs
            pkgs.cargo
            pkgs.python310
          ];
        };
      };
    };
}
