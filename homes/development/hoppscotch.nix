# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  home.packages = [ pkgs.hoppscotch ];

  clicks.storage.impermanence.persist.directories = [
    ".config/io.hoppscotch.desktop/"
    ".local/share/hoppscotch-desktop"
  ];
}
