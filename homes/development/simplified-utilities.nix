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
    pkgs.doggo
    pkgs.fd
    pkgs.sd
  ];
}
