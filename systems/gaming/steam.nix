# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
