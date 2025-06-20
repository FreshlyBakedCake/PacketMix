# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ catppuccin }:
{ project, lib, ... }:
{
  imports = [ catppuccin.result.homeManagerModules.catppuccin ];
  config.catppuccin.enable = true;
  config.catppuccin.gtk.enable = true;
}
