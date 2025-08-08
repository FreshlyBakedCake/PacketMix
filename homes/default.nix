# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
let
  nixpkgs = config.inputs.nixpkgs.result;
in
{
  config.homes."maya:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/maya";
      }
      (import ./catppuccin { inherit (config.inputs) catppuccin; })
      ./common
      ./development
      ./espanso
      ./gaming
      ./maya
      (import ./niri { inherit (config.inputs) niri walker home-manager-unstable; })
      (import ./nix-index { inherit (config.inputs) nix-index-database; })
      ./remote
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      (import ./catppuccin { inherit (config.inputs) catppuccin; })
      ./common
      ./development
      ./espanso
      ./gaming
      ./minion
      (import ./niri { inherit (config.inputs) niri walker home-manager-unstable; })
      (import ./nix-index { inherit (config.inputs) nix-index-database; })
      ./remote
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.homes."minion@redhead:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      (import ./catppuccin { inherit (config.inputs) catppuccin; })
      ./common
      ./development
      ./espanso
      ./gaming
      ./minion
      (import ./niri { inherit (config.inputs) niri walker home-manager-unstable; })
      (import ./nix-index { inherit (config.inputs) nix-index-database; })
      (import ./redhead { inherit (config.inputs) impermanence; })
      ./remote
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
      (import ./catppuccin { inherit (config.inputs) catppuccin; })
      ./coded
      ./common
      ./development
      ./espanso
      ./gaming
      (import ./niri { inherit (config.inputs) niri walker home-manager-unstable; })
      (import ./nix-index { inherit (config.inputs) nix-index-database; })
      ./remote
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.homes."pinea:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/pinea";
      }
      (import ./catppuccin { inherit (config.inputs) catppuccin; })
      ./pinea
      ./common
      ./development
      ./espanso
      ./gaming
      (import ./nix-index { inherit (config.inputs) nix-index-database; })
      ./remote
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
