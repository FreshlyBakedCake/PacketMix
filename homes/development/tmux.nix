# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  programs.tmux.enable = true;
  programs.fzf.tmux.enableShellIntegration = true; # Needed for using sesh - which relies on fzf+tmux
  programs.sesh.enable = true;
}
