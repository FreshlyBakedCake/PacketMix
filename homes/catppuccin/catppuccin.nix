# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }: {
  imports = [ project.inputs.catppuccin.result.homeModules.catppuccin ];
  config.catppuccin.enable = true;
  config.catppuccin.gtk.enable = true;
}
