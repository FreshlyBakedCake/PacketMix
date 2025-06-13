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
      theme = "catppuccin_latte";

      editor = {
        bufferline = "multiple";

        line-number = "relative";
        lsp.display-inlay-hints = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };
      };

      keys.normal = {
        space.E = {
          command = "@mip<space>e";
          label = "Hard-wrap (rEflow) current paragraph";
        };
        space.e = {
          command = ":reflow";
          label = "Hard-wrap (rEflow) selected text";
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          formatter = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          };
        }
      ];
    };
  };
}
