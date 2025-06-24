# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.uutils-coreutils-noprefix
    pkgs.uutils-findutils
    pkgs.uutils-diffutils
  ];
}
