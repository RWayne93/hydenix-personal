# modules/hm/theme.nix
{ ... }:

{
# Theme configuration - isolated and organized
hydenix.hm.theme = {
    enable = true;
    active = "Tokyo Night";

    themes = [
        "Catppuccin Mocha"
        "Catppuccin Latte"
        "Tokyo Night"
        "Another World"
    ];

    };
}