# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  xdg.configFile."espanso/config/default.yml".text = builtins.toJSON {
    search_trigger = ":search";
    show_notifications = false;
    keyboard_layout = {
      model = config.home.keyboard.model;
      layout = config.home.keyboard.layout;
      variant = config.home.keyboard.variant;

      options = builtins.concatStringsSep "," config.home.keyboard.options;
    };
  };
}
