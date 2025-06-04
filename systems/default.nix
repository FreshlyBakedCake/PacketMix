# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.systems.nixos."redhead" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      ./common
      ./personal
      ./redhead
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."emden" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      ./common
      ./emden
      ./personal
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."midnight" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      ./common
      ./midnight
      ./server
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
  config.systems.nixos."teal" = {
    pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    modules = [
      ./common
      ./teal
      ./server
    ];
    args = {
      system = "x86_64-linux";
      monorepo = config;
    };
  };
}
