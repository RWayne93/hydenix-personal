{ lib, pkgs, ... }:

{
  home.packages = [
    pkgs.k9s
  ];

  # Minimal config to enable the wallbash skin.
  home.file.".config/k9s/config.yaml".text = ''
    k9s:
      ui:
        skin: wallbash
  '';

  # Install the wallbash template as a real file so wallbash can pick it up,
  # and ensure the skins directory exists so generation won't be skipped.
  home.activation.installK9sWallbash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    base_dir="$HOME/.local/share/wallbash"
    skins_dir="$HOME/.config/k9s/skins"
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
    mkdir -p "$skins_dir"
    cat >"$dcol_dir/k9s.dcol" <<'EOF'
    ''${XDG_CONFIG_HOME:-$HOME/.config}/k9s/skins/wallbash.yaml
    # Wallbash skin by HyDE-Project!
    k9s:
      # General K9s styles
      body:
        fgColor: "<wallbash_txt1>" # Foreground
        bgColor: "<wallbash_pry1>" # Background
        logoColor: "<wallbash_1ax3>" # Logo
      # ClusterInfoView styles.
      info:
        fgColor: "<wallbash_txt1>" # Foreground
        sectionColor: "<wallbash_1ax2>" # Section headers
      # Help panel styles
      help:
        fgColor: "<wallbash_txt1>" # Foreground
        bgColor: "<wallbash_pry1>" # Background
        keyColor: "<wallbash_1ax4>" # Key bindings
        numKeyColor: "<wallbash_1ax5>" # Numeric keys
        sectionColor: "<wallbash_1ax2>" # Section headers
      frame:
        # Borders styles.
        border:
          fgColor: "<wallbash_pry3>" # Border
          focusColor: "<wallbash_1ax2>" # Focused border
        # MenuView attributes and styles.
        menu:
          fgColor: "<wallbash_txt1>" # Foreground
          # Style of menu text. Supported options are "dim" (default), "normal", and "bold"
          fgStyle: normal
          keyColor: "<wallbash_1ax4>" # Key bindings
          # Used for favorite namespaces
          numKeyColor: "<wallbash_1ax5>" # Numeric keys
        # CrumbView attributes for history navigation.
        crumbs:
          fgColor: "<wallbash_txt1>" # Foreground
          bgColor: "<wallbash_pry4>" # Slightly lighter background
          activeColor: "<wallbash_pry3>" # Active crumb
        # Resource status and update styles
        status:
          newColor: "<wallbash_1ax3>" # New items
          modifyColor: "<wallbash_1ax2>" # Modified items
          addColor: "<wallbash_1ax4>" # Added items
          errorColor: "<wallbash_pry3>" # Error state
          highlightcolor: "<wallbash_1ax5>" # Highlighted items
          killColor: "<wallbash_pry3>" # Kill status
          completedColor: "<wallbash_2ax7>" # Completed items
        # Border title styles.
        title:
          fgColor: "<wallbash_1ax2>" # Title text
          bgColor: "<wallbash_pry1>" # Title background
          highlightColor: "<wallbash_pry3>" # Highlighted title
          counterColor: "<wallbash_1ax5>" # Counter
          filterColor: "<wallbash_1ax4>" # Filter indicator
      views:
        # TableView attributes.
        table:
          fgColor: "<wallbash_txt1>" # Table text
          bgColor: "<wallbash_pry1>" # Table background
          cursorColor: "<wallbash_1ax2>" # Cursor
          # Header row styles.
          header:
            fgColor: "<wallbash_pry3>" # Header text
            bgColor: "<wallbash_pry4>" # Header background
            sorterColor: "<wallbash_1ax2>" # Sort indicator
        # YAML info styles.
        yaml:
          keyColor: "<wallbash_pry3>" # YAML keys
          colonColor: "<wallbash_txt1>" # Colon separator
          valueColor: "<wallbash_1ax3>" # YAML values
        # Logs styles.
        logs:
          fgColor: "<wallbash_txt1>" # Log text
          bgColor: "<wallbash_pry1>" # Log background
          indicator:
            fgColor: "<wallbash_1ax2>" # Log indicator
            bgColor: "<wallbash_pry1>" # Indicator background
            toggleOnColor: "<wallbash_1ax3>" # Toggle on
            toggleOffColor: "<wallbash_2ax7>" # Toggle off
    EOF
  '';
}

