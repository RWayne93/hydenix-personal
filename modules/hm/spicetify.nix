{ lib, pkgs, ... }:

let
  sleekTar = pkgs.fetchurl {
    url = "https://github.com/HyDE-Project/HyDE/raw/master/Source/arcs/Spotify_Sleek.tar.gz";
    sha256 = "sha256-K9BVTOcVvoiQ60oce1YRFAkwTcRzjOAVGZ9/QHDBPa4=";
  };
in
{
  home.packages = [
    pkgs.spicetify-cli
  ];

  # Install wallbash template + script for Spicetify/Sleek without network downloads.
  home.activation.installSpicetifyWallbash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    base_dir="$HOME/.config/wallbash"
    scripts_dir="$base_dir/scripts"
    always_dir="$base_dir/always"
    themes_dir="$HOME/.config/spicetify/Themes"

    if [ -L "$base_dir" ] || [ ! -d "$base_dir" ]; then
      rm -rf "$base_dir"
      mkdir -p "$base_dir"
    fi
    chmod -R u+w "$base_dir" 2>/dev/null || true

    mkdir -p "$scripts_dir" "$always_dir" "$themes_dir"

    # Install the Sleek theme from HyDE (no network calls).
    if [ ! -d "$themes_dir/Sleek" ]; then
      ${pkgs.gnutar}/bin/tar --use-compress-program=${pkgs.gzip}/bin/gzip -xf ${sleekTar} -C "$themes_dir"
    fi

    cat > "$scripts_dir/spotify.sh" <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail

    command -v spicetify >/dev/null 2>&1 || exit 0

    spotify_bin="$(command -v spotify || true)"
    if [ -n "$spotify_bin" ]; then
      spotify_path="$(dirname "$(readlink -f "$spotify_bin")")"
    elif [ -d "''${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify" ]; then
      spotify_path="''${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
    elif [ -d "/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify" ]; then
      spotify_path="/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
    fi

    if [ -n "''${spotify_path:-}" ]; then
      spicetify config spotify_path "$spotify_path" >/dev/null 2>&1 || true
    fi

    mkdir -p "$HOME/.config/spotify"
    touch "$HOME/.config/spotify/prefs"
    spicetify config prefs_path "$HOME/.config/spotify/prefs" >/dev/null 2>&1 || true

    spicetify config current_theme Sleek >/dev/null 2>&1 || true
    spicetify config color_scheme Wallbash >/dev/null 2>&1 || true
    spicetify config sidebar_config 0 >/dev/null 2>&1 || true

    if [ -n "''${spotify_path:-}" ] && [ -w "$spotify_path" ] && [ -w "$spotify_path/Apps" ]; then
      # Ensure backup exists before applying; skip silently if Spotify isn't in a clean state.
      spicetify backup apply >/dev/null 2>&1 || exit 0
      spicetify apply >/dev/null 2>&1 || true
    fi
    EOF
    chmod 755 "$scripts_dir/spotify.sh"

    cat > "$always_dir/spotify.dcol" <<'EOF'
    $HOME/.config/spicetify/Themes/Sleek/color.ini|''${WALLBASH_SCRIPTS}/spotify.sh

    [Wallbash]
    text               = <wallbash_4xa9>
    subtext            = <wallbash_4xa8>
    nav-active-text    = <wallbash_4xa7>
    main               = <wallbash_pry1>
    sidebar            = <wallbash_pry1>
    player             = <wallbash_pry1>
    card               = <wallbash_pry1>
    shadow             = <wallbash_1xa1>
    main-secondary     = <wallbash_2xa2>
    button             = <wallbash_3xa8>
    button-secondary   = <wallbash_3xa7>
    button-active      = <wallbash_3xa6>
    button-disabled    = <wallbash_pry2>
    nav-active         = <wallbash_3xa2>
    play-button        = <wallbash_3xa3>
    tab-active         = <wallbash_pry2>
    notification       = <wallbash_pry1>
    notification-error = <wallbash_pry1>
    playback-bar       = <wallbash_pry1>
    misc               = <wallbash_pry2>
    EOF
    chmod 644 "$always_dir/spotify.dcol"
  '';
}

