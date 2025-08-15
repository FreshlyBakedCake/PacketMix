# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

# depends on niri flavor
# depends on catppuccin flavor
# depends on development flavor
{
  imports = [
    ./bitwarden.nix
    ./calendar.nix
    ./catppuccin.nix
    ./email.nix
    ./jujutsu.nix
    ./niri.nix
    ./sesh.nix
  ];
}
