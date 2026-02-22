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
  imports = [
    (import "${project.inputs.lix-module.result}/module.nix" { lix = project.inputs.lix.src; })
  ];

  nix.settings = {
    experimental-features = [ "nix-command" ];
    deprecated-features = [
      "broken-string-escape"
      "or-as-identifier"
    ];
  };

  nix.gc = {
    automatic = true;
    persistent = true;
    options = "--delete-older-than 7d";
    dates = "08:30";
  };

  nixpkgs.overlays = [
    (final: prev: {
      nix-monitored = project.inputs.nix-monitored.result.packages.${system}.default.override {
        nix = final.lix;
        withNotify = pkgs.stdenv.isLinux;
      };
      nixos-rebuild = prev.nixos-rebuild.override {
        nix = final.nix-monitored;
      };
      nix-direnv = prev.nix-direnv.override {
        nix = final.nix-monitored;
      };
    })
  ];

  nix.package = pkgs.nix-monitored;
}
