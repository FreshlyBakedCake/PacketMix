# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [
    project.inputs.impermanence.result.nixosModules.impermanence
    ./ghostty.nix
    ./locale.nix
    ./packetmix.nix
    ./ssh.nix
    ./users.nix
  ];
}
