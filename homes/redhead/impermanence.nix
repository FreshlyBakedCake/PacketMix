# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ impermanence }:
{ ... }:
{
  imports = [
    impermanence.result.homeManagerModules.impermanence
  ];

  clicks.storage.impermanence.enable = true;
}
