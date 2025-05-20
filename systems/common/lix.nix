# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ monorepo, ... }: {
  imports = [
    monorepo.inputs.lix-module.result.nixosModules.default
  ];

  nix.settings.experimental-features = [ "nix-command" ];

  nix.gc = {
    automatic = true;
    persistent = true;
    options = "--delete-older-than 7d";
    dates = "08:30";
  };
}
