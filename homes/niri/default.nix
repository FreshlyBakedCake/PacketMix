# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ niri, walker }:
{
  imports = [
    (import ./niri.nix { inherit niri walker; })
    ./swaync.nix
  ];
}
