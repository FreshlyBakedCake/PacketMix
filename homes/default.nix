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
    ];
    ingredients = [
      "catppuccin"
      "collabora"
      "common"
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "maya"
      "niri"
      "nix-index"
      "remote"
      "scriptfs"
    ];
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
    ];
    ingredients = [
      "catppuccin"
      "common"
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "minion"
      "niri"
      "nix-index"
      "remote"
      "scriptfs"
    ];
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
    ];
    ingredients = [
      "catppuccin"
      "collabora"
      "common"
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "minion"
      "niri"
      "nix-index"
      "redhead"
      "remote"
      "scriptfs"
    ];
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
    ];
    ingredients = [
      "catppuccin"
      "coded"
      "common"
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "niri"
      "nix-index"
      "remote"
      "scriptfs"
    ];
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
    ];
    ingredients = [
      "catppuccin"
      "common"
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "nix-index"
      "pinea"
      "remote"
      "scriptfs"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
}
