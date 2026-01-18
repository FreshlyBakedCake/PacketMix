# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config.homes."packetmix-maya:x86_64-linux" = {
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
      "nix-index"
      "remote"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."packetmix-minion:x86_64-linux" = {
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
      "nightshift"
      "nix-index"
      "remote"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."packetmix-minion@redhead:x86_64-linux" = {
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
      "nightshift"
      "nix-index"
      "remote"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
  config.homes."packetmix-coded:x86_64-linux" = {
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
      "nix-index"
      "remote"
    ];
    args = {
      system = "x86_64-linux";
    };
  };
}
