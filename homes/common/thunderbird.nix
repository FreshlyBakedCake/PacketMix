# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.thunderbird
  ];

  clicks.storage.impermanence.persist.directories = [
    ".mozilla/thunderbird"
    ".thunderbird"
  ];
}
