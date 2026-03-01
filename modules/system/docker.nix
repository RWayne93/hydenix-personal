{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
  ];

  # Allow your user to run docker without sudo.
  users.users.nixie.extraGroups = [ "docker" ];
}