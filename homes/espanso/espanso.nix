# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
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
}
