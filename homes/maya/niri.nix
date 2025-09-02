# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
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
  ingredient.niri.enable = true;

  programs.niri = {
    settings = {
      input.mouse.natural-scroll = true;
      layout.gaps = lib.mkForce 0;
    };
  };

  ingredient.niri.niri.wallpaper = ../minion/wallpaper.png;
  ingredient.niri.niri.overviewBackground = pkgs.stdenv.mkDerivation {
    name = "niri-overview-background";

    src = ../minion/overviewBackground.png;
    dontUnpack = true;

    buildPhase = ''
      ${pkgs.imagemagick}/bin/magick $src -blur 0x4 -fill black -colorize 40% $out
    '';
  };
}
