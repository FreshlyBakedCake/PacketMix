# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  services.udev.packages = [
    pkgs.platformio-core.udev
  ];

  users.users.minion.extraGroups = [ "dialout" ];
}
