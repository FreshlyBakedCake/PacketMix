# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  home.packages = [ pkgs.vlc ];

  clicks.storage.impermanence.persist.directories = [
    ".config/aacs"
  ];
}
