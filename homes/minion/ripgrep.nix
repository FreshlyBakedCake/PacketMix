# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.ripgrep = {
    enable = true;

    arguments = [
      "--smart-case"
    ];
  };
}
