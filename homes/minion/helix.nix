# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.helix = {
    settings = {
      theme = "catppuccin_latte_packetmix";
    };

    themes = {
      catppuccin_latte_packetmix = {
        inherits = "catppuccin_latte";
        "ui.virtual.whitespace" = "surface0"; # The default catppuccin_latte theme displays rendered whitespace way too harshly...
      };
    };
  };
}
