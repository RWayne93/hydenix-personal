{ ... }:

{
  hydenix.hm.hyprland.windowrules.extraConfig = ''
    windowrule = opacity 0.80 0.80 1, class:^(dev.warp.Warp)$
    windowrule = opacity 0.80 0.80 1, class:^(cursor)$
    windowrule = opacity 0.80 0.80 1, class:^(dev.zed.Zed)$

    windowrulev2 = float,title:^(Sign in to Security Device)$
    windowrulev2 = size 600 400,title:^(Sign in to Security Device)$
    windowrulev2 = center,title:^(Sign in to Security Device)$
  '';
}

