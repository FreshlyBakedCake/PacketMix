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
      ./catppuccin/catppuccin.nix
      ./common/default.nix
      ./development/deafult.nix
      ./gaming/default.nix
      ./minion/default.nix
      (import ./niri/niri.nix { inherit (config.inputs) niri walker; })
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.homes."coded:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/coded";
      }
      ./catppuccin/catppuccin.nix
      ./coded/default.nix
      ./common/default.nix
      ./development/deafult.nix
      ./gaming/default.nix
      (import ./niri/niri.nix { inherit (config.inputs) niri walker; })
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
