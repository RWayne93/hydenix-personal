{ lib, pkgs, ... }:

let
  nssDbDir = "$HOME/.pki/nssdb";
  openscModule = "/run/current-system/sw/lib/opensc-pkcs11.so";
in
{
  home.packages = [
    pkgs.nssTools
  ];

  # Register OpenSC in the user's NSS DB (Chrome/Chromium use this on Linux)
  home.activation.registerOpenSC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ${nssDbDir} ]; then
      ${pkgs.nssTools}/bin/certutil -d sql:${nssDbDir} -N --empty-password
    fi

    if ! ${pkgs.nssTools}/bin/modutil -dbdir sql:${nssDbDir} -list | grep -q "OpenSC PKCS#11 Module"; then
      ${pkgs.nssTools}/bin/modutil \
        -dbdir sql:${nssDbDir} \
        -add "OpenSC PKCS#11 Module" \
        -libfile ${openscModule} \
        -force >/dev/null 2>&1 || true
    fi
  '';
}

