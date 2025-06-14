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
      theme = "catppuccin_latte_packetmix";

      editor = {
        bufferline = "multiple";

        line-number = "relative";
        lsp.display-inlay-hints = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };

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

    themes = {
      catppuccin_latte_packetmix = {
        inherits = "catppuccin_latte";
        "ui.virtual.whitespace" = "surface0"; # The default catppuccin_latte theme displays rendered whitespace way too harshly...
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
