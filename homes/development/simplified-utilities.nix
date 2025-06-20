# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.ripgrep = {
    enable = true;

    arguments = [
      "--smart-case"
    ];
  };

  home.packages = [
    pkgs.sd
    pkgs.fd
  ];
}
