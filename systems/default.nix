# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  ...
}:
let
  nixpkgs = config.inputs.nixpkgs.result;
in
{
  config.systems.nixos."packetmix-redhead" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "javelin"
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = {
      "minion@redhead:x86_64-linux" = config.homes."packetmix-minion@redhead:x86_64-linux";
    };
  };
  config.systems.nixos."packetmix-emden" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "javelin"
      "personal"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = {
      "minion:x86_64-linux" = config.homes."packetmix-minion:x86_64-linux";
    };
  };
  config.systems.nixos."packetmix-marbled" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "javelin"
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = {
      "maya:x86_64-linux" = config.homes."packetmix-maya:x86_64-linux";
      "minion:x86_64-linux" = config.homes."packetmix-minion:x86_64-linux";
    };
  };
  config.systems.nixos."packetmix-ocicat" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "personal"
      "portable"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = {
      "coded:x86_64-linux" = config.homes."packetmix-coded:x86_64-linux";
    };
  };
  config.systems.nixos."packetmix-shorthair" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "corsair"
      "personal"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = {
      "coded:x86_64-linux" = config.homes."packetmix-coded:x86_64-linux";
    };
  };
  config.systems.nixos."packetmix-midnight" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "freshlybakedcake"
      "nix-serve"
      "server"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.systems.nixos."packetmix-teal" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "freshlybakedcake"
      "server"
      "wiki"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.systems.nixos."packetmix-umber" = {
    pkgs = nixpkgs.x86_64-linux;
    ingredients = [
      "freshlybakedcake"
      "server"
      "wiki"
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
