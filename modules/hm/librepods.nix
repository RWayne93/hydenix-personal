{
  inputs,
  pkgs,
  ...
}:
let
  # NVIDIA + Wayland: wgpu's GL/EGL path panics in khronos-egl
  # (`Option::unwrap()` on a null EGL display). Vulkan works.
  librepodsPkg = inputs.librepods.packages.${pkgs.system}.default.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/librepods \
        --set WGPU_BACKEND vulkan
    '';
  });
in
{
  home.packages = [ librepodsPkg ];

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
