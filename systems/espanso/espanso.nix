# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, config, ... }:
{
  services.espanso = {
    enable = true;
    package = if config.services.xserver.enable then pkgs.espanso else pkgs.espanso-wayland;
  };

  programs.espanso.capdacoverride.enable = !config.services.xserver.enable;
}
