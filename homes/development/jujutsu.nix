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
    pkgs.kdiff3
    pkgs.mergiraf
    project.inputs.nixos-unstable.result.${system}.jujutsu
  ];
}
