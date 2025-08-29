# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
  home.file = {
    ".cache/espanso/kvs/has_completed_wizard" = {
      enable = true;
      text = "true";
    };
    ".cache/espanso/kvs/has_displayed_welcome" = {
      enable = true;
      text = "true";
    };
  };
  xdg.configFile."espanso/config/default.yml".text = builtins.toJSON (
    {
      search_trigger = ":search";
      show_notifications = false;
    }
    // (
      if (config.home.keyboard != null) then
        {
          keyboard_layout = {
            inherit (config.home.keyboard) layout model variant;

            options = builtins.concatStringsSep "," config.home.keyboard.options;
          };
        }
      else
        { }
    )
  );

  clicks.storage.impermanence.persist.directories = [
    ".config/espanso/match"
  ];
}
