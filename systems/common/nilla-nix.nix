# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  environment.systemPackages = [
    project.inputs.nilla-cli.result.packages.nilla-cli.result.${system}
    project.inputs.nilla-home.result.packages.nilla-home.result.${system}
    project.inputs.nilla-nixos.result.packages.nilla-nixos.result.${system}
  ];
}
