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
      "common"
      "espanso"
      "freshlybakedcake"
      "javelin"
      "minion"
      "niri"
      "personal"
      "portable"
      "redhead"
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
      "common"
      "emden"
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
      "common"
      "espanso"
      "freshlybakedcake"
      "javelin"
      "marbled"
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
      "common"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "niri"
      "ocicat"
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
      "common"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "kde"
      "personal"
      "pinea"
      "saurosuchus"
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
      "common"
      "corsair"
      "espanso"
      "freshlybakedcake"
      "gaming"
      "niri"
      "personal"
      "shorthair"
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
      "common"
      "freshlybakedcake"
      "midnight"
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
      "common"
      "freshlybakedcake"
      "teal"
      "server"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
