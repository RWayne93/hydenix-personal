{ ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        # Firefox OpenSC registration kept here for quick rollback.
        # "OpenSC PKCS#11 Module" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        "smartcard-rs PKCS#11 Module" = "/home/nixie/smartcard-rs/target/release/libsmartcard_pkcs11.so";
      };
    };
  };
}

