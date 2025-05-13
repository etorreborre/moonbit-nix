{
  pkgs,
  lib,
  system,
  version ? "latest",
  ...
}:
let
  # we need moonbit1 to build moonbit-core
  moonbit1 = pkgs.stdenv.mkDerivation {
    pname = "moonbit";
    inherit version;

    src = builtins.fetchTarball {
      url = "https://cli.moonbitlang.com/binaries/${version}/moonbit-aarch64-darwin.tar.gz";
      sha256 = "sha256:12njiz7chsd5mz36dydy9fkipx8l0if81rwzll22qs0k9yi978ka";
    };

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    buildInputs = [ pkgs.libgcc ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      for file in $src/*;do
        ext=$(echo "$file" | sed 's/.*\.//')
        case "$ext" in
          "a" | "o" | "h")
            cp "$file" $out/bin;;
          *)
            install -m 755 "$file" $out/bin
        esac
      done
      runHook postInstall
    '';
  };
  moonbit-core = pkgs.callPackage ./moonbit-core.nix { moonbit = moonbit1; };
in
  {
inherit  moonbit-core;
moonbit = moonbit1.overrideAttrs (oldAttrs: rec {
  postInstall = ''
    wrapProgram $out/bin/moon --set MOON_HOME ${moonbit-core}/
  '';

  meta = with lib; {
    description = "The Moonbit programming language";
    homepage = "https://www.moonbitlang.com/";
    platforms = platforms.darwin;
    mainProgram = "moon";
  };
});
}
