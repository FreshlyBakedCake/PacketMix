# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.eza.override {
      gitSupport = false;
      exaAlias = false;
    })
  ];
}
