{ config, ... }:

{
  services.tailscale.enable = true;

  # Native nftables support for clean Tailscale integration
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Force tailscaled to use nftables (avoids iptables-compat translation issues)
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # Wait for network before starting tailscale
  systemd.services.tailscaled.after = [ "network-online.target" ];
  systemd.services.tailscaled.wants = [ "network-online.target" ];
}
