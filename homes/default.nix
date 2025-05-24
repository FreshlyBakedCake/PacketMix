# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      ({ pkgs, ... }: {
        home.packages = [ pkgs.hello ];
      })
      ./minion/direnv.nix
      ./minion/logger.nix
      ./minion/ripgrep.nix
      ./minion/zoxide.nix
    ];
    args = {
      system = "x86_64-linux";
#      monorepo = config;
      attrToLog = "it works!";
    };
  };
}
