{
  description = "template for hydenix";

  nixConfig = {
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs = {
      # url = "github:nixos/nixpkgs/nixos-unstable"; # uncomment this if you know what you're doing
      follows = "hydenix/nixpkgs"; # then comment this
    };
    nixpkgs-cursor.url = "github:nixos/nixpkgs/nixos-unstable";
    hydenix.url = "github:florianvazelle/hydenix";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    librepods.url = "github:kavishdevar/librepods/linux/rust";
    claude-code.url = "github:sadjow/claude-code-nix?ref=v2";
  };

  outputs =
    { ... }@inputs:
    let
      system = "x86_64-linux";
      hydenixConfig = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
        ];
      };
    in
    {
      nixosConfigurations.hydenix = hydenixConfig;
      nixosConfigurations.default = hydenixConfig;
      packages.${system}.vm = hydenixConfig.config.system.build.vm;
    };
}
