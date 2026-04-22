{ lib, pkgs, ... }:

let
  nssDbDir = "$HOME/.pki/nssdb";
  # smartcardModule = "/run/current-system/sw/lib/opensc-pkcs11.so";
  smartcardModule = "/home/nixie/smartcard-rs/target/release/libsmartcard_pkcs11.so";
in
{
  home.packages = [
    pkgs.nssTools
  ];

  home.activation.registerSmartcardRs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${nssDbDir}

    if [ ! -f "${nssDbDir}/cert9.db" ]; then
      ${pkgs.nssTools}/bin/certutil -d sql:${nssDbDir} -N --empty-password
    fi

    # Keep the old OpenSC module name here for rollback reference.
    # ${pkgs.nssTools}/bin/modutil -dbdir sql:${nssDbDir} -add "OpenSC PKCS#11 Module" -libfile /run/current-system/sw/lib/opensc-pkcs11.so -force

    # Chrome/Chromium read the user's NSS DB, so just ensure our module exists.
    if ! ${pkgs.nssTools}/bin/modutil -dbdir sql:${nssDbDir} -list | grep -q "smartcard-rs"; then
      ${pkgs.nssTools}/bin/modutil \
        -dbdir sql:${nssDbDir} \
        -add "smartcard-rs" \
        -libfile ${smartcardModule} \
        -force
    fi
  '';
}

