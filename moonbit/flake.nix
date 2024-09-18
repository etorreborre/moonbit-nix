{
  description = "moonbit nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      moonbit = pkgs.stdenv.mkDerivation {
        pname = "moonbit";
        version = "1.0.0";

        src = builtins.fetchTarball {
          url = "https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz";
          sha256 = "sha256:0hxanlky5adb531l8s1290w2lhnlrw92m1iqjfgw0v7ipgrwv0qx";
        };

        sourceRoot = ".";
        dontConfigure = true;
        dontBuild = true;

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
        ];

        buildInputs = [ pkgs.libgcc ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          for file in $src/*;do
            install -m 755 "$file" $out/bin
          done
          runHook postInstall
        '';
      };
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
