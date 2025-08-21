# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  # depends on scriptfs ingredient for jujutsu
  imports = [
    ./collaboration.nix
    ./direnv.nix
    ./gpg.nix
    ./helix.nix
    ./hoppscotch.nix
    ./jujutsu.nix
    ./simplified-utilities.nix
    ./tmux.nix
  ];
}
