# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [
    project.inputs.catppuccin.result.homeModules.catppuccin
    "${project.inputs.home-manager-unstable.src}/modules/programs/vivid.nix" # Needed for latest catppuccin...
  ];
  config.catppuccin.enable = true;

  config.catppuccin.cursors.enable = true;
  config.home.pointerCursor.enable = true;
}
