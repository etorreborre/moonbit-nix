{
  pkgs,
  lib,
  system,
  moonbit,
  version ? "latest",
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "moonbit-core";
  inherit version;

  src = builtins.fetchTarball {
    url = "https://cli.moonbitlang.com/cores/core-${version}.tar.gz";
    sha256 = "sha256:0bs3xvw0767l8i1g5qsd4d4y3dvlpx09hwnx7720cqns1a67iyby";
  };

  sourceRoot = ".";
  dontConfigure = true;

  MOON_PATH = "${moonbit}/bin/";

  unpackPhase = ''
    mkdir -p $out/lib/core
    cp -r $src/* $out/lib/core
  '';

  buildPhase = ''
    runHook preBuild
    export PATH=${moonbit}/bin:$PATH
    export MOON_HOME=$out
    moon bundle --all --source-dir $out/lib/core
    moon bundle --target wasm-gc --source-dir $out/lib/core --quiet    
    runHook postBuild
  '';
}
