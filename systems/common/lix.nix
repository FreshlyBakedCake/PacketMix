# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }: {
  imports = [
    (import "${project.inputs.lix-module.result}/module.nix" { lix = project.inputs.lix.src; })
  ];

  nix.settings.experimental-features = [ "nix-command" ];

  nix.gc = {
    automatic = true;
    persistent = true;
    options = "--delete-older-than 7d";
    dates = "08:30";
  };
}
