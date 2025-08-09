# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.firefox.enable = true;

  clicks.storage.impermanence.persist.directories = [
    ".mozilla/firefox"
  ];
}
