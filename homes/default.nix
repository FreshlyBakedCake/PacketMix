# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }: let
  nixpkgs = config.inputs.nixpkgs.result;
in {
  config.homes."minion:x86_64-linux" = {
    modules = [
      {
        home.stateVersion = "24.11";
        home.homeDirectory = "/home/minion";
      }
      ./common
      ./development
      ./minion
      (import ./niri { inherit (config.inputs) niri walker; })
    ];
    args = {
      system = "x86_64-linux";
      project = config;
    };
  };
}
