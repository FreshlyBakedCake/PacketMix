# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ catppuccin }:
{ project, lib, ... }:
{
  imports = [ catppuccin.result.homeModules.catppuccin ];
  config.catppuccin.enable = true;
}
