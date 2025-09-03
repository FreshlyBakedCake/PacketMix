# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # Miscellaneous package installs that aren't really big enough to get their own folder
  # Don't place any config that isn't directly adding lines to home.packages here...
  home.packages = [
    pkgs.libreoffice
    pkgs.obs-studio
  ];
}
