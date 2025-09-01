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
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
    ];
    ingredients = [
      "catppuccin"
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
  config.homes."coded:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "25.05";
        home.homeDirectory = "/home/coded";
      }
    ];
    ingredients = [
      "catppuccin"
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
      "development"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "nix-index"
      "remote"
      "scriptfs"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
}
