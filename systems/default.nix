{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.systems.nixos."redhead" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      {
        networking.hostName = "redhead";
      }
      ./common/configuration.nix
      ./common/nilla-nix.nix
      ./common/nixpkgs.nix
      ./common/packetmix.nix
      ./redhead/hardware-configuration.nix
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
  config.systems.nixos."emden" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      {
        networking.hostName = "emden";
      }
      ./common/configuration.nix
      ./common/nilla-nix.nix
      ./common/nixpkgs.nix
      ./common/packetmix.nix
      ./emden/hardware-configuration.nix
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
}
