# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.fish.enable = true;

  clicks.storage.impermanence.persist.directories = [
    ".config/fish"
    ".local/share/fish"
    ".terminfo"
  ];
}
