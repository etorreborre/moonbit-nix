{
  description = "moonbit nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";

    ocaml-overlay.url = "github:nix-ocaml/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ocaml-overlay,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      mbt = pkgs.callPackage ./pkgs/moonbit.nix { };
      ocaml_overlay = final: prev: {
        ocamlPackages = prev.ocaml-ng.ocamlPackages_5_2;
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
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
        moonbit = mbt.moonbit;
        moonbit-core = mbt.moonbit-core;
        default = mbt.moonbit;
      };

      devShells.${system} =
        let
          ext = inputs.nix-vscode-extensions.extensions.${system};
          vscode = pkgs.vscode-with-extensions.override {
            vscodeExtensions = [
              ext.vscode-marketplace.moonbit.moonbit-lang
              ext.vscode-marketplace.ms-vscode.cpptools-extension-pack
            ];
          };
        in
        rec {
          default = moonbit-dev;

          # moonbit dev shell/environment
          moonbit-dev = pkgs.mkShell {
            nativeBuildInputs = [ mbt.moonbit ];
            packages = [ vscode ];
          };

          rescript-compiler-dev =
            let
              ext = inputs.nix-vscode-extensions.extensions.${system};
              vscode = pkgs.vscode-with-extensions.override {
                vscodeExtensions = [
                  ext.vscode-marketplace.ms-vscode.makefile-tools
                  pkgs.vscode-extensions.ocamllabs.ocaml-platform
                ];
              };
            in
            pkgs.mkShell {
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

                vscode
              ];
            };
        };
    };
}
