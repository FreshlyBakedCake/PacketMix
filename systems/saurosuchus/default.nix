# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./hostname.nix
  ];

  environment.systemPackages = [ pkgs.firefox pkgs.chromium ];
}
