{ ... }:

{
  hydenix.hm.hyprland.windowrules.extraConfig = ''
    windowrule = opacity 0.80 0.80 1, match:class ^(dev.warp.Warp)$
    windowrule = opacity 0.80 0.80 1, match:class ^(cursor)$
    windowrule = opacity 0.80 0.80 1, match:class ^(dev.zed.Zed)$

    # Chromium/PKCS#11 smartcard unlock prompt (empty class; actual title is "Unlock security device")
    windowrule = float true, size (600) (400), center true, group deny, match:title ^(Unlock security device)$
    windowrule = float true, size (600) (400), center true, group deny, match:title ^(Sign in to Security Device)$
    windowrule = float true, size (600) (400), center true, group deny, match:initial_title ^(Unlock security device)$
    windowrule = float true, size (600) (400), center true, group deny, match:initial_title ^(Sign in to Security Device)$
  '';
}
