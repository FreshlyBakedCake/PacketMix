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
    };
  };

  niri.wallpaper = ../minion/wallpaper.png;
  niri.overviewBackground = pkgs.stdenv.mkDerivation {
    name = "niri-overview-background";

    src = ../minion/overviewBackground.png;
    dontUnpack = true;

    buildPhase = ''
      ${pkgs.imagemagick}/bin/magick $src -blur 0x4 -fill black -colorize 40% $out
    '';
  };
}
