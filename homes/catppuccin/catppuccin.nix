# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ catppuccin }:
{ project, lib, ... }:
{
  imports = [ catppuccin.result.homeModules.catppuccin ];
  config.catppuccin.enable = true;

  config.catppuccin.cursors.enable = true;
  config.home.pointerCursor.enable = true;
}
