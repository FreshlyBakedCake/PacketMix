# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ nix-index-database }:
{
  imports = [
    (import ./nix-index.nix { inherit nix-index-database; })
  ];
}
