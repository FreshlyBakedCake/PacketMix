# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  fonts.packages = [
    pkgs.cantarell-fonts
    pkgs.carlito
    pkgs.corefonts
    pkgs.fira-code
    pkgs.fira-sans
    pkgs.nerd-fonts.symbols-only
  ];

  fonts.enableDefaultPackages = true;
}
