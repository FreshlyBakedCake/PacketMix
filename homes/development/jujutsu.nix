# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  system,
  ...
}:
{
  home.packages = [
    pkgs.difftastic
    pkgs.meld
    project.inputs.nixos-unstable.result.${system}.jujutsu
  ];
}
