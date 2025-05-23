# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  niri.wallpaper = ./wallpaper.png;
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
          x = 3840;
          y = 0;
        };
        mode = {
          width = 3840;
          height = 2160;
          refresh = 144.;
        };
      };
      "DP-2" = {
        position = {
          x = 0;
          y = 0;
        };
        mode = {
          width = 3840;
          height = 2160;
          refresh = 144.;
        };
      };
      "LG Electronics LG TV SSCR2 0x01010101" = {
        position = {
          x = 0;
          y = -2160;
        };
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.;
        };
      };
      "Dell Inc. DELL S2422HG BTTCK83" = {
        position = {
          x = -1920;
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
