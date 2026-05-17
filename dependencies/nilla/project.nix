# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  includes = builtins.filter builtins.pathExists [
    ./cli/project.nix
    ./home/project.nix
    ./nixos/project.nix
  ];
}
