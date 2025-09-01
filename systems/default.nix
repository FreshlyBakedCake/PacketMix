# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
let
  nixpkgs = config.inputs.nixpkgs.result;
in
{
  config.systems.nixos."redhead" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "espanso"
      "freshlybakedcake"
      "javelin"
      "minion"
      "niri"
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion@redhead:x86_64-linux"; };
  };
  config.systems.nixos."emden" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "espanso"
      "freshlybakedcake"
      "gaming"
      "javelin"
      "minion"
      "niri"
      "personal"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."marbled" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "espanso"
      "freshlybakedcake"
      "javelin"
      "minion"
      "niri"
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "maya:x86_64-linux" "minion:x86_64-linux"; };
  };
  config.systems.nixos."ocicat" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "coded"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "niri"
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."saurosuchus" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "espanso"
      "freshlybakedcake"
      "gaming"
      "kde"
      "personal"
      "pinea"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "pinea:x86_64-linux"; };
  };
  config.systems.nixos."shorthair" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "coded"
      "corsair"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "niri"
      "personal"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."midnight" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "freshlybakedcake"
      "server"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.systems.nixos."teal" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "freshlybakedcake"
      "server"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
