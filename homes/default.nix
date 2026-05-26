# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, config, ... }:
{
  config.homesDir = ./.;
  config.homes =
    let
      minion = [
        "catppuccin"
        "development"
        "espanso"
        "freshlybakedcake"
        "nightshift"
        "nix-index"
        "remote"
      ];
      collabora = [
        "collabora"
      ];
    in
    {
      "packetmix-maya:x86_64-linux" = {
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
      "packetmix-minion@collabora:x86_64-linux" = {
        modules = [
          {
            home.stateVersion = "24.11";
            home.homeDirectory = "/home/minion";
          }
        ];
        ingredients = minion ++ collabora;
        args = {
          system = "x86_64-linux";
        };
      };
      "packetmix-minion@redhead-collabora:x86_64-linux" = {
        modules = [
          {
            home.stateVersion = "24.11";
            home.homeDirectory = "/home/minion";
          }
        ];
        ingredients =
          minion
          ++ collabora
          ++ [
            "redhead"
          ];
        args = {
          system = "x86_64-linux";
        };
      };
      "packetmix-minion@redhead-unspecialised:x86_64-linux" = {
        modules = [
          {
            home.stateVersion = "24.11";
            home.homeDirectory = "/home/minion";
          }
        ];
        ingredients = minion ++ [
          "gaming"
          "redhead"
          "unspecialised"
        ];
        args = {
          system = "x86_64-linux";
        };
      };
      "packetmix-coded:x86_64-linux" = {
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
    };
}
