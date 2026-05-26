# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  environment.systemPackages = [
    project.packages.nilla-cli.result.${system}
    project.packages.nilla-home.result.${system}
    project.packages.nilla-nixos.result.${system}
  ];
}
