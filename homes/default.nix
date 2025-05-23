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
      ./minion/direnv.nix
      ./minion/ripgrep.nix
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
  config.homes."coded:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/coded";
      }
      ./coded/default.nix
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
}
