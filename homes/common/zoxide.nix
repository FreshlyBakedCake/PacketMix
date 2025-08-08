# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd=cd"
      "--hook=prompt"
    ];
  };

  clicks.storage.impermanence.persist.directories = [
    ".local/share/zoxide"
  ];
}
