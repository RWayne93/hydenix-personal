{ lib, pkgs, config, ... }:

let
  freerdpCustom = pkgs.freerdp.overrideAttrs (old: {
    # Ensure we build with Wayland, audio, and smartcard support
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-DWITH_WAYLAND=ON"
      "-DWITH_PULSE=ON"
      "-DWITH_ALSA=ON"
      "-DWITH_PCSC=ON"
      "-DWITH_SMARTCARD=ON"
    ];
    buildInputs = (old.buildInputs or []) ++ [
      pkgs.wayland
      pkgs.libpulseaudio
      pkgs.alsa-lib
      pkgs.pcsclite
    ];
    postPatch = (old.postPatch or "") + ''
      # Replace client/common/client.c with the patched file from this repo
      cp ${./patches/freerdp-client.c} client/common/client.c
    '';
  });
in
{
  options.hydenix.system.freerdp = {
    enable = lib.mkEnableOption "Enable FreeRDP with Wayland/audio/smartcard";
  };

  config = lib.mkIf config.hydenix.system.freerdp.enable {
    environment.systemPackages = [
      freerdpCustom
    ];
  };
}

