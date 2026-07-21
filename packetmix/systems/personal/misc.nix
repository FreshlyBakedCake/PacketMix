# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  project,
  pkgs,
  config,
  system,
  ...
}:
{
  environment.systemPackages = [
    project.packages.packetmix-nilla-init.result.${system}
    project.packages.packetmix-npins.result.${system}
    pkgs.ghostty
    pkgs.wl-clipboard
  ];
}
