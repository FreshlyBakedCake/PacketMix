# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ home-manager-unstable }:
{ project, system, ... }:
{
  imports = [ "${home-manager-unstable.src}/modules/programs/quickshell.nix" ];

  programs.quickshell = {
    enable = true;

    package = project.inputs.nixos-unstable.result.${system}.quickshell; # Since as we have directly imported the module from home-manager, quickshell isn't in nixpkgs yet for us...

    activeConfig = "sprinkles";
    configs.sprinkles = ./.;

    systemd = {
      enable = true;
      target = "niri.service";
    };
  };

  programs.niri.settings.layer-rules = [
    {
      matches = [
        { namespace = "^quickshell$"; }
      ];
      place-within-backdrop = true;
    }
  ];
}
