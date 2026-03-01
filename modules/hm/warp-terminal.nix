{ lib, pkgs, ... }:

let
  warpTerminal = pkgs.callPackage ../../pkgs/warp-terminal.nix { };
  warpThemes = pkgs.fetchFromGitHub {
    owner = "warpdotdev";
    repo = "themes";
    rev = "main";
    hash = "sha256-8GHUFs1XAIuT+hF41n2zSMePTjaC2PCcVAFApVe6LDA=";
  };
  hydeWarpThemes = pkgs.fetchFromGitHub {
    owner = "HyDE-Project";
    repo = "terminal-emulators";
    rev = "main";
    hash = "sha256-ijJVNFuRMeWN/7ZeagpjL/xoHket+yH9e5o5IB6opd0=";
  };
  hydeWarpThemeDir = pkgs.runCommand "hyde-warp-theme-dir" { } ''
    mkdir -p "$out/hyde"
    ln -s ${hydeWarpThemes}/warp/* "$out/hyde/"
  '';
  mergedWarpThemes = pkgs.symlinkJoin {
    name = "warp-themes-merged";
    paths = [
      warpThemes
      hydeWarpThemeDir
    ];
  };
in
{
  home.packages = [
    warpTerminal
  ];

  # Install Warp themes as real files (no store symlinks) so hyde-shell can write hyde.yaml
  home.activation.installWarpThemes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.local/share/warp-terminal/themes"
    preserved_hyde_yaml=""
    if [ -f "$target/hyde/hyde.yaml" ]; then
      preserved_hyde_yaml="$(mktemp)"
      cp -f "$target/hyde/hyde.yaml" "$preserved_hyde_yaml"
    fi

    rm -rf "$target"
    mkdir -p "$target"
    # -L dereferences symlinks so files are copied into $HOME
    cp -aL ${mergedWarpThemes}/. "$target/"
    chmod -R u+w "$target"

    if [ -n "$preserved_hyde_yaml" ] && [ -f "$preserved_hyde_yaml" ]; then
      mkdir -p "$target/hyde"
      cp -f "$preserved_hyde_yaml" "$target/hyde/hyde.yaml"
      rm -f "$preserved_hyde_yaml"
    fi

    # Ensure wallbash dirs are real and writable (HyDE may symlink these to the store).
    base_dir="$HOME/.local/share/wallbash"
    if [ -L "$base_dir" ] || [ ! -d "$base_dir" ]; then
      rm -rf "$base_dir"
      mkdir -p "$base_dir"
    fi
    chmod -R u+w "$base_dir" 2>/dev/null || true

    dcol_dir="$base_dir/always"
    if [ -L "$dcol_dir" ] || [ ! -d "$dcol_dir" ]; then
      rm -rf "$dcol_dir"
      mkdir -p "$dcol_dir"
    fi
    cp -aL ${hydeWarpThemes}/warp/warp-terminal.dcol "$dcol_dir/warp-terminal.dcol"
  '';

}

