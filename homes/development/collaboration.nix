# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = project.inputs.nixos-unstable.result.${system}.zed-editor;
    extensions = [
      "catppuccin"
      "catppuccin-icons"
      "nix"
    ];
    userSettings = {
      git.git_gutter = "hide";
      minimap.show = "auto";
      helix_mode = true;
    };
  };
}
