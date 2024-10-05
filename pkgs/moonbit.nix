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
    sha256 = "sha256:05aag1xji5hwidj7sdgk5clzjrqxr5352zx640mghk0flvw3g6w9";
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
