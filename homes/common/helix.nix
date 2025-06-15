# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  project,
  system,
  ...
}:
{
  programs.helix = {
    enable = true;

    package = project.packages.helix.result.${system};

    settings = {
      editor = {
        bufferline = "multiple";
        line-number = "relative";
      };
    };
  };
}
