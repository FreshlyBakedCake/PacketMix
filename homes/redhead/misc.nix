# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # Miscellaneous package installs that aren't really big enough to get their own folder
  # Don't place any config that isn't directly adding lines to home.packages or clicks.storage.impermanence.persist.directories here...
  home.packages = [
    pkgs.brightnessctl
  ];

  clicks.storage.impermanence.persist.directories = [
    # used for some ephemeral android shells...
    ".android"
    ".cache/Google"
    ".config/Google"
    ".gradle"
    ".local/share/Google"
  ];
}
