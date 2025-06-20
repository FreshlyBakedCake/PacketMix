# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ catppuccin }:
{
  imports = [
    (import ./catppuccin.nix { inherit catppuccin; })
  ];
}
