{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.systems.nixos."redhead" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      ./redhead/configuration.nix
      ./redhead/hardware-configuration.nix
      ./redhead/nilla.nix
      ./redhead/packetmix.nix
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
}
