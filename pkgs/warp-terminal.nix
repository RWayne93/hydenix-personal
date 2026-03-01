{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zstd,
  alsa-lib,
  curl,
  fontconfig,
  libglvnd,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xdg-utils,
  xorg,
  zlib,
  xz,
  makeWrapper,
  waylandSupport ? false,
}:

let
  pname = "warp-terminal";
  version = "0.2026.02.25.08.24.stable_01";
  
  linux_arch = if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64" else "aarch64";
in

stdenv.mkDerivation rec {
  inherit pname version;
  
  src = fetchurl {
    url = "https://releases.warp.dev/stable/v${version}/${pname}-v${version}-1-${linux_arch}.pkg.tar.zst";
    hash = if linux_arch == "x86_64" then
      "sha256-PBDITM/Zc6rj91knMIu4QvwF6NRJ8fxzq8Btd01ens0=" else
      "sha256-/baDz+NFH6rCYF5r9iSXL6k3Aa+Cew8/FQPIoY5lwOU=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    zstd
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    curl
    fontconfig
    (lib.getLib stdenv.cc.cc)
    zlib
    xz
  ];

  runtimeDependencies = [
    libglvnd
    libxkbcommon
    stdenv.cc.libc
    vulkan-loader
    xdg-utils
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
  ] ++ lib.optionals waylandSupport [ wayland ];

  postPatch = ''
    if [ -f usr/bin/warp-terminal ]; then
      substituteInPlace usr/bin/warp-terminal \
        --replace-fail /opt/ $out/opt/
    fi
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r opt usr/* $out

    ${lib.optionalString waylandSupport ''
      wrapProgram $out/bin/warp-terminal --set WARP_ENABLE_WAYLAND 1
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Warp is the intelligent terminal with AI and your dev team's knowledge built-in";
    homepage = "https://www.warp.dev";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}

