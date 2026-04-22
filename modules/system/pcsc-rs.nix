{ lib, config, ... }:

{
  options.hydenix.system.pcsc-rs = {
    enable = lib.mkEnableOption "Enable pcsc-rs as the system PC/SC daemon";
  };

  config = lib.mkIf config.hydenix.system.pcsc-rs.enable {
    systemd.sockets.pcscd-rs = {
      description = "pcsc-rs smart card daemon socket";
      wantedBy = [ "sockets.target" ];
      conflicts = [ "pcscd.socket" ];

      socketConfig = {
        ListenStream = "/run/pcscd-rs/pcscd-rs.comm";
        Service = "pcscd-rs.service";
        SocketMode = "0666";
        DirectoryMode = "0755";
        RemoveOnStop = true;
      };
    };

systemd.services.pcscd-rs = {
  description = "pcsc-rs smart card daemon";
  conflicts = [ "pcscd.service" "pcscd.socket" ];
  after = [ "local-fs.target" ];

  environment = {
    PCSCD_RS_TRACE = "1";
  };

  serviceConfig = {
    Type = "simple";
    ExecStart = "/home/nixie/pcsc-rs/target/release/pcscd-rs --foreground";
    Restart = "on-failure";
  };
    };
  };
}
