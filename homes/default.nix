{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
}
