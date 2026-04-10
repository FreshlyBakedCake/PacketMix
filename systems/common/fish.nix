# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
