# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [
    project.inputs.impermanence.result.homeManagerModules.impermanence
  ];

  clicks.storage.impermanence.enable = true;
}
