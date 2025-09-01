# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
let
  nixpkgs = config.inputs.nixpkgs.result;

  modules = config.lib.ingredients.collectIngredientsModules ./. { project = config; };
in
{
  config.homes."maya:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/maya";
      }
      {
        ingredient = {
          catppuccin.enable = true;
          collabora.enable = true;
          common.enable = true;
          development.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          gaming.enable = true;
          maya.enable = true;
          niri.enable = true;
          nix-index.enable = true;
          remote.enable = true;
          scriptfs.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      {
        ingredient = {
          catppuccin.enable = true;
          common.enable = true;
          development.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          gaming.enable = true;
          minion.enable = true;
          niri.enable = true;
          nix-index.enable = true;
          remote.enable = true;
          scriptfs.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."minion@redhead:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      {
        ingredient = {
          catppuccin.enable = true;
          collabora.enable = true;
          common.enable = true;
          development.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          gaming.enable = true;
          minion.enable = true;
          niri.enable = true;
          nix-index.enable = true;
          redhead.enable = true;
          remote.enable = true;
          scriptfs.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."coded:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/coded";
      }
      {
        ingredient = {
          catppuccin.enable = true;
          coded.enable = true;
          common.enable = true;
          development.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          gaming.enable = true;
          niri.enable = true;
          nix-index.enable = true;
          remote.enable = true;
          scriptfs.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."pinea:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/pinea";
      }
      {
        ingredient = {
          catppuccin.enable = true;
          common.enable = true;
          development = true;
          espanso = true;
          freshlybakedcake.enable = true;
          gaming.enable = true;
          nix-index.enable = true;
          pinea.enable = true;
          remote.enable = true;
          scriptfs.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
    };
  };
}
