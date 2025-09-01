# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, lib, ... }:
{
  imports = [ project.inputs.catppuccin.result.homeModules.catppuccin ];
  config.catppuccin.enable = true;

  config.catppuccin.cursors.enable = true;
  config.home.pointerCursor.enable = true;
}
