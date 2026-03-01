{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.twingate
  ];

  # Install and enable the Twingate systemd unit from the package.
  systemd.packages = [ pkgs.twingate ];
  # systemd.services.twingate.wantedBy = [ "multi-user.target" ];
  systemd.services.twingate.unitConfig.ConditionPathExists = "/etc/twingate/config.json";

  # Ensure /etc/twingate exists as a real directory for `twingate setup`.
  systemd.tmpfiles.rules = [
    "d /etc/twingate 0755 root root -"
  ];

  # Provide a default config.json so the service can start.
  environment.etc."twingate/config.json".source =
    "${pkgs.twingate}/etc/twingate/config.json";
}

