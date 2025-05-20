# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ monorepo, ... }: {
  imports = [
    monorepo.inputs.impermanence.result.nixosModules.impermanence
    ./locale.nix
    ./ssh.nix
  ];
}
