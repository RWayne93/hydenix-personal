{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        "smartcard-rs PKCS#11 Module" = "/home/nixie/smartcard-rs/target/release/libsmartcard_pkcs11.so";
      };
    };
  };
}

