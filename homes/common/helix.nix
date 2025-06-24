# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
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

        auto-save.focus-lost = true;

        whitespace.render = {
          space = "none";
          tab = "all";
          nbsp = "all";
          nnbsp = "all";
          newline = "none";
        };
        whitespace.characters = {
          tabpad = "-";
          tab = "-";
        };
      };
    };
  };

  home.sessionVariables.EDITOR = "${config.programs.helix.package}/bin/hx";
}
