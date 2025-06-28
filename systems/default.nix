# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
let
  nixpkgs = config.inputs.nixpkgs.result;
in
{
  config.systems.nixos."redhead" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./collabora
      ./common
      ./espanso
      ./javelin
      ./minion
      ./niri
      ./personal
      ./redhead
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."emden" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./espanso
      ./gaming
      ./javelin
      ./minion
      ./emden
      ./niri
      ./personal
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion:x86_64-linux"; };
  };
  config.systems.nixos."ocicat" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./espanso
      ./gaming
      ./niri
      ./ocicat
      ./personal
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."midnight" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./midnight
      ./server
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
  config.systems.nixos."teal" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./teal
      ./server
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
