# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "catppuccin"
      "catppuccin-icons"
      "nix"
    ];
    userSettings = {
      edit_predictions.mode = "subtle";
      git.git_gutter = "hide";
      minimap.show = "auto";
      vim_mode = true;
    };
  };
}
