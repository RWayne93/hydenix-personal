{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        "OpenSC PKCS#11 Module" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      };
    };
  };
}

