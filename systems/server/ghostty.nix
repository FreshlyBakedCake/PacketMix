# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  programs.bash = {
    interactiveShellInit = ''
      if [[ "$TERM" == "xterm-ghostty" ]]; then
        builtin source ${pkgs.ghostty.shell_integration}/bash/ghostty.bash
      fi
    '';
  };
}
