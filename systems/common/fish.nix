# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set fish_greeting
  ''; # Clear out the fish greeting variable so the default greeting doesn't activate on, e.g., sudo. We will override the greeting function in special cases where we want something to show

  users.defaultUserShell = pkgs.fish;
}
