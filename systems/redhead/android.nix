# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }: {
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  users.users.minion.extraGroups = [ "adbusers" ];
}
