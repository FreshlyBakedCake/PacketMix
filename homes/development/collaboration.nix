# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
  options.zed.vim_mode = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config.programs.zed-editor = {
    enable = true;
    extensions = [
      "catppuccin"
      "catppuccin-icons"
      "nix"
    ];
    userSettings = {
      git.git_gutter = "hide";
      minimap.show = "auto";
      vim_mode = config.zed.vim_mode;
    };
  };
}
