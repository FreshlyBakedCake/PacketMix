# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  programs.helix = {
    settings = {
      theme = lib.mkForce "catppuccin_latte_packetmix";
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
          name = "rust";
        }
      ];
      language-server.rust-analyzer.config = {
        cargo.allFeatures = true;
        diagnostics.disabled = [ "proc-macro-disabled" ];
        procMacro.ignored.leptos_macro = [ "server" ];
      };
    };
  };
}
