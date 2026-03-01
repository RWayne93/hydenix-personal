{ pkgs, ... }:

{
  imports = [
    # ./example.nix - add your modules here
    ./freerdp.nix
    ./twingate.nix
    ./docker.nix
  ];

  environment.systemPackages = [
    # pkgs.vscode - managed via home-manager now
    # pkgs.userPkgs.vscode - your personal nixpkgs version

    pkgs.gnome-keyring
    pkgs.libsecret
    pkgs.seahorse
    pkgs.opensc
    pkgs.pcsc-tools
    pkgs.ccid
    pkgs.gnupg
    pkgs.pinentry-gnome3
    pkgs.procps
    pkgs.nvtopPackages.full
    pkgs.p11-kit
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
  environment.etc."pkcs11/modules/opensc.module".text = ''
    module: ${pkgs.opensc}/lib/opensc-pkcs11.so
  '';


  # Unlock keyring on login (PAM) - SDDM is your display manager
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Ensure D-Bus session is available for secret service
  services.dbus.enable = true;
}
