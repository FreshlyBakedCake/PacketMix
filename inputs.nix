# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

let
  pins = import ./npins;

  settings = {
    nixpkgs.configuration.allowUnfree = true;
    "nixos-24.11" = settings.nixpkgs;
    nixos-unstable = settings.nixpkgs;
  };
in
{ config, ... }:
{
  config.inputs = builtins.mapAttrs (name: value: {
    src = value;
    settings = settings.${name} or config.lib.constants.undefined;
  }) pins;
}
