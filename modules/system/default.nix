{ pkgs, ... }:

let
  kio-s3 = pkgs.callPackage ../../pkgs/kio-s3.nix {
    inherit (pkgs.kdePackages)
      extra-cmake-modules
      kio
      ki18n
      kconfig
      kcmutils
      kirigami-addons
      kdoctools
    ;
  };
in

{
  imports = [
    # ./example.nix - add your modules here
    ./freerdp.nix
    ./twingate.nix
    ./tailscale.nix
    ./docker.nix
    ./certs.nix
    ./claude-code.nix
    ./sleep.nix
  ];

  environment.systemPackages = [
    kio-s3
    # pkgs.vscode - managed via home-manager now
    # pkgs.userPkgs.vscode - your personal nixpkgs version

    pkgs.gnome-keyring
    pkgs.openssl
    pkgs.libsecret
    pkgs.seahorse
    #pkgs.opensc
    pkgs.pcsc-tools
    pkgs.ccid
    pkgs.gnupg
    pkgs.pinentry-gnome3
    pkgs.procps
    pkgs.nvtopPackages.full
    pkgs.p11-kit
    pkgs.wl-clipboard
  ];

  services.gnome.gnome-keyring.enable = true;
  services.pcscd.enable = true;
  services.pcscd.plugins = [ pkgs.ccid ];

  # Enable FreeRDP build with Wayland/audio/smartcard
  hydenix.system.freerdp.enable = true;

  # GnuPG agent for smartcard-backed x509 signing via gpgsm
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # Register OpenSC via p11-kit (used by apps that consume p11-kit)
  # environment.etc."pkcs11/modules/opensc.module".text = ''
  #   module: ${pkgs.opensc}/lib/opensc-pkcs11.so
  # '';

  # Unlock keyring on login (PAM) - SDDM is your display manager
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Allow LAN access to local development/services.
  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 8081 ];
  };

  # Ensure D-Bus session is available for secret service
  services.dbus.enable = true;
}
