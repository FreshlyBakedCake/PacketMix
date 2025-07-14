# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ nix-index-database }:
{ ... }:
{
  imports = [
    nix-index-database.result.homeModules.nix-index
  ];

  config = {
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;
  };
}
