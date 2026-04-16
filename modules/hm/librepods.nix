{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.librepods.packages.${pkgs.system}.default
  ];

  xdg.desktopEntries.librepods = {
    name = "LibrePods";
    genericName = "AirPods Manager";
    comment = "AirPods liberated from Apple's ecosystem";
    exec = "librepods";
    terminal = false;
    categories = [
      "AudioVideo"
      "Utility"
    ];
  };
}
