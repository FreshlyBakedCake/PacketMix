# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  niri,
  walker,
  home-manager-unstable,
}:
{
  imports = [
    (import ./niri.nix { inherit niri walker; })
    (import ./quickshell { inherit home-manager-unstable; })
    ./swaync.nix
  ];
}
