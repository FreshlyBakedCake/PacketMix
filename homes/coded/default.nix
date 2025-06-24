# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

# depends on niri flavor
# depends on catppuccin flavor
# depends on development flavor
{
  imports = [
    ./appimage.nix
    ./bitwarden.nix
    ./calendar.nix
    ./catppuccin.nix
    ./email.nix
    ./keyboard.nix
    ./niri.nix
    ./sesh.nix
  ];
}
