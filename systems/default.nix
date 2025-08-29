# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
let
  nixpkgs = config.inputs.nixpkgs.result;

  modules = config.lib.ingredients.collectIngredientsModules ./.;
in
{
  config.systems.nixos."redhead" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          javelin.enable = true;
          minion.enable = true;
          niri.enable = true;
          personal.enable = true;
          portable.enable = true;
          redhead.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion@redhead:x86_64-linux"; };
  };
  config.systems.nixos."emden" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          gaming.enable = true;
          javelin.enable = true;
          minion.enable = true;
          emden.enable = true;
          niri.enable = true;
          personal.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."marbled" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          javelin.enable = true;
          minion.enable = true;
          niri.enable = true;
          personal.enable = true;
          portable.enable = true;
          marbled.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "maya:x86_64-linux" "minion:x86_64-linux"; };
  };
  config.systems.nixos."ocicat" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          coded.enable = true;
          common.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          gaming.enable = true;
          niri.enable = true;
          ocicat.enable = true;
          personal.enable = true;
          portable.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."saurosuchus" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          gaming.enable = true;
          kde.enable = true;
          personal.enable = true;
          pinea.enable = true;
          saurosuchus.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "pinea:x86_64-linux"; };
  };
  config.systems.nixos."shorthair" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          coded.enable = true;
          common.enable = true;
          corsair.enable = true;
          espanso.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+personal".enable = true;
          gaming.enable = true;
          niri.enable = true;
          shorthair.enable = true;
          personal.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."midnight" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+server".enable = true;
          midnight.enable = true;
          server.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.systems.nixos."teal" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      {
        ingredient = {
          common.enable = true;
          freshlybakedcake.enable = true;
          "freshlybakedcake+server".enable = true;
          teal.enable = true;
          server.enable = true;
        };
      }
    ]
    ++ modules;
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
