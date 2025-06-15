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
    settings = {
      editor = {
        lsp.display-inlay-hints = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };

        indent-guides.render = true;
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
