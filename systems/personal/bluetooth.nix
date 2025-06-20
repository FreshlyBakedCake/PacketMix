# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.overskride ];

  hardware.bluetooth.enable = true;
}
