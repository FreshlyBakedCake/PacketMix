# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  ingredient.niri.enable = true;

  ingredient.niri.swayidle.timers = {
    lock = 900;
    sleep = 1800;
  };
  ingredient.niri.niri.wallpaper = ./wallpaper.png;
  programs.niri.settings = {
    input.mouse.natural-scroll = false;
    outputs = {
      "eDP-1" = {
        position = {
          x = 0;
          y = 0;
        };
      };
      "DP-1" = {
        position = {
          x = 5760;
          y = 0;
        };
        mode = {
          width = 3840;
          height = 2160;
          refresh = 144.;
        };
        scale = 1;
      };
      "DP-2" = {
        position = {
          x = 1920;
          y = 0;
        };
        mode = {
          width = 3840;
          height = 2160;
          refresh = 144.;
        };
        scale = 1;
      };
      "Dell Inc. DELL S2422HG BTTCK83" = {
        position = {
          x = 0;
          y = 540;
        };
        mode = {
          width = 1920;
          height = 1080;
          refresh = 164.997;
        };
      };
    };
  };
}
