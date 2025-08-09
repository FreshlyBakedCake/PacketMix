# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.chromium.enable = true;

  clicks.storage.impermanence.persist.directories = [
    ".config/chromium"
  ];
}
