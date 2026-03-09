# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
let
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
    withJava = true;
  };
  vlc = pkgs.vlc.override { inherit libbluray; };
in
{
  home.packages = [ vlc ];

  clicks.storage.impermanence.persist.directories = [
    ".config/aacs"
  ];
}
