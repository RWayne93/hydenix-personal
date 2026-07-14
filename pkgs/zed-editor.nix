{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  alsa-lib,
  libcap,
  libxkbcommon,
  libglvnd,
  vulkan-loader,
  wayland,
  xorg,
  glib,
}:

let
  pname = "zed-editor";
  version = "1.9.0";
  channel = "stable";
  x86Hash = "sha256-OeVTzjoA/ut46rY6XLcjfLRg88lZaxsZBSzre56OxN0=";
  aarch64Hash = "sha256-/hwCwaC8GOu09n+TaGKpROapfGajZm7gvyzLrEfi6Dw=";

  linuxArch =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64"
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      "aarch64"
    else
      throw "Unsupported system for ${pname}: ${stdenv.hostPlatform.system}";

  # Zed bundles many shared objects, but still expects core system libs
  # (e.g. libasound) to exist on the host.
  runtimeLibs = [
    alsa-lib
    glib
    libcap
    libxkbcommon
    libglvnd
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    name = "zed-linux-${linuxArch}.tar.gz";
    url = "https://cloud.zed.dev/releases/${channel}/${version}/download?asset=zed&arch=${linuxArch}&os=linux&source=nix";
    hash = if linuxArch == "x86_64" then x86Hash else aarch64Hash;
  };

  nativeBuildInputs = [ makeWrapper ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib" "$out/share/applications"
    cp -r zed.app "$out/lib/zed.app"

    # Recent builds provide bin/zed; keep a fallback for older layouts.
    if [ -f "$out/lib/zed.app/bin/zed" ]; then
      makeWrapper "$out/lib/zed.app/bin/zed" "$out/bin/zed" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
    else
      makeWrapper "$out/lib/zed.app/bin/cli" "$out/bin/zed" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
    fi

    desktop_src="$out/lib/zed.app/share/applications/dev.zed.Zed.desktop"
    desktop_dst="$out/share/applications/dev.zed.Zed.desktop"
    cp "$desktop_src" "$desktop_dst"
    substituteInPlace "$desktop_dst" \
      --replace-fail "Exec=zed" "Exec=$out/bin/zed" \
      --replace-fail "Icon=zed" "Icon=$out/lib/zed.app/share/icons/hicolor/512x512/apps/zed.png"

    runHook postInstall
  '';

  meta = with lib; {
    description = "High-performance, multiplayer code editor from the creators of Atom";
    homepage = "https://zed.dev";
    license = licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "zed";
  };
}
