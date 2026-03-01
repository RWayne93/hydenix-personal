{ lib, pkgs, ... }:

{
  # Sync Cursor theme from HyDE's current GTK theme whenever wallbash runs.
  home.activation.installCursorWallbashSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    base_dir="$HOME/.local/share/wallbash"
    scripts_dir="$base_dir/scripts"
    always_dir="$base_dir/always"

    if [ -L "$base_dir" ] || [ ! -d "$base_dir" ]; then
      rm -rf "$base_dir"
      mkdir -p "$base_dir"
    fi

    mkdir -p "$scripts_dir" "$always_dir" "$HOME/.cache/hyde/wallbash"

    cat > "$scripts_dir/wallbash-cursor.sh" <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail

    theme_conf="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/themes/theme.conf"
    cursor_settings="''${XDG_CONFIG_HOME:-$HOME/.config}/Cursor/User/settings.json"

    [ -f "$theme_conf" ] || exit 0
    gtk_theme=$(grep -E '^\$GTK_THEME' "$theme_conf" | head -n1 | sed -E 's/^[^=]+= *//')
    gtk_theme=''${gtk_theme//\"/}
    [ -n "$gtk_theme" ] || exit 0

    # Map HyDE GTK theme naming (Tokyo-Night) to Cursor theme naming (Tokyo Night).
    cursor_theme="''${gtk_theme//-/ }"

    case "$cursor_theme" in
      Tokyo\ Night*|Catppuccin\ Mocha*|Catppuccin\ Latte*)
        ;;
      *)
        # Fall back to the Wallbash theme for any other theme name.
        cursor_theme="wallbash"
        ;;
    esac

    mkdir -p "$(dirname "$cursor_settings")"
    [ -f "$cursor_settings" ] || echo "{}" > "$cursor_settings"
    tmp="$(mktemp)"
    ${pkgs.jq}/bin/jq --arg theme "$cursor_theme" \
      '.["workbench.colorTheme"]=$theme' "$cursor_settings" > "$tmp" && mv "$tmp" "$cursor_settings"
    EOF
    chmod 755 "$scripts_dir/wallbash-cursor.sh"

    cat > "$always_dir/cursor-theme.dcol" <<'EOF'
    ''${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wallbash/cursor.json|''${XDG_DATA_HOME:-$HOME/.local/share}/wallbash/scripts/wallbash-cursor.sh
    {}
    EOF
    chmod 644 "$always_dir/cursor-theme.dcol"
  '';
}

