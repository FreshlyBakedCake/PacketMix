# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  system,
  ...
}:
{
  # Miscellaneous package installs that aren't really big enough to get their own folder
  # Don't place any config that isn't directly adding lines to home.packages or clicks.storage.impermanence.persist.directories here...
  home.packages = [
    pkgs.obs-studio
    pkgs.signal-desktop
    pkgs.unzip
    pkgs.zip
  ];

  clicks.storage.impermanence.persist.directories = [
    ".config/obs-studio"
    ".config/Signal"
  ];
}
