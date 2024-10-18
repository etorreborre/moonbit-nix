{
  pkgs,
  lib,
  system,
  version ? "latest",
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "moonbit";
  inherit version;

  src = builtins.fetchTarball {
    url = "https://cli.moonbitlang.com/binaries/${version}/moonbit-linux-x86_64.tar.gz";
    sha256 = "sha256:0hjg147b5jnymrni8a8vzxzqfaf03bdvp4xjx1qrsi5g1l683fn0";
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

  meta = with lib; {
    description = "The Moonbit programming language";
    homepage = "https://www.moonbitlang.com/";
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "moon";
  };
}
