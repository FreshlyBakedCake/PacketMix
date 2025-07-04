# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.niri = {
    settings = {
      input.mouse.natural-scroll = true;
      outputs = {
        "eDP-1" = {
          # frame.work laptop internal monitor
          position = {
            x = 1200;
            y = 1560;
          };
        };
        "Hewlett Packard LA2405 CN40370NRF" = {
          # work left monitor
          position = {
            x = 0;
            y = 0;
          };
          transform.rotation = 270;
        };
        "Hewlett Packard LA2405 CN40500PYR" = {
          # work right monitor
          position = {
            x = 1200;
            y = 360;
          };
        };
        "Dell Inc. DELL P2715Q V7WP95AV914L" = {
          # emden mid-monitor
          position = {
            x = 1080;
            y = 120;
          };
          scale = 1.5;
        };
        "PNP(AOC) 2460G5 0x00014634" = {
          # emden left monitor
          position = {
            x = 0;
            y = 0;
          };
          transform.rotation = 270;
        };
        "PNP(AOC) 2460G5 0x00023C3F" = {
          # emden right monitor
          position = {
            x = 3640;
            y = 300;
          };
        };
      };
    };
  };

  niri.wallpaper = ./wallpaper.png;
}
