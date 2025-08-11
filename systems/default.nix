# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
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
      ./common
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
      ./javelin
      ./minion
      ./niri
      ./personal
      ./portable
      ./redhead
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "minion@redhead:x86_64-linux"; };
  };
  config.systems.nixos."emden" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
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
  config.systems.nixos."marbled" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
      ./javelin
      ./minion
      ./niri
      ./personal
      ./portable
      ./marbled
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "maya:x86_64-linux" "minion:x86_64-linux"; };
  };
  config.systems.nixos."ocicat" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./coded
      ./common
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
      ./gaming
      ./niri
      ./ocicat
      ./personal
      ./portable
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "coded:x86_64-linux"; };
  };
  config.systems.nixos."saurosuchus" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./common
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
      ./gaming
      ./kde
      ./personal
      ./pinea
      ./saurosuchus
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
    homes = { inherit (config.homes) "pinea:x86_64-linux"; };
  };
  config.systems.nixos."shorthair" = {
    pkgs = nixpkgs.x86_64-linux;
    modules = [
      ./coded
      ./common
      ./corsair
      ./espanso
      ./freshlybakedcake
      ./freshlybakedcake+personal
      ./gaming
      ./niri
      ./shorthair
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
      ./freshlybakedcake
      ./freshlybakedcake+server
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
      ./freshlybakedcake
      ./freshlybakedcake+server
      ./teal
      ./server
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
