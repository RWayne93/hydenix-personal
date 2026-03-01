{
  config,
  inputs,
  pkgs,
  ...
}:

let
  cursorPkgs = import inputs.nixpkgs-cursor {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in

{
  imports = [
    # ./example.nix - add your modules here
    ./firefox.nix
    ./vscode.nix
    ./theme.nix
    ./windowrules.nix
    ./warp-terminal.nix
    ./cursor-wallbash.nix
    ./k9s.nix
    ./spicetify.nix
    ./uv.nix
    ./direnv.nix
    ./chrome-opensc.nix
    ./carmy-rdp.nix
  ];

  # home-manager options go here
  home.packages = [
    cursorPkgs.code-cursor
    pkgs.google-chrome
    pkgs.kdePackages.okular
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  hydenix.hm.enable = true;
  hydenix.hm.editors.enable = true;
  hydenix.hm.editors.vscode.enable = false;
  hydenix.hm.firefox.enable = false;
  hydenix.hm.spotify.enable = false;

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
  };

  home.sessionVariables.BROWSER = "firefox";

  home.file.".config/electron-flags.conf".force = true;

  hydenix.hm.hyprland.extraConfig = ''
    exec-once = dbus-update-activation-environment --systemd --all
    exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP
  '';
  
  # Visit https://github.com/richen604/hydenix/blob/main/docs/options.md for more options
}
