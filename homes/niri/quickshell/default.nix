# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ home-manager-unstable }:
{
  project,
  system,
  config,
  pkgs,
  ...
}:
{
  imports = [ "${home-manager-unstable.src}/modules/programs/quickshell.nix" ];

  programs.quickshell = {
    enable = true;

    package = project.inputs.nixos-unstable.result.${system}.quickshell; # Since as we have directly imported the module from home-manager, quickshell isn't in nixpkgs yet for us...

    activeConfig = "sprinkles";
    configs.sprinkles = pkgs.stdenv.mkDerivation {
      name = "sprinkles-config";

      src = ./.;
      dontUnpack = true;

      buildPhase = ''
        mkdir -p $out

        cp -r $src/*.qml $out
        cp ${config.niri.overviewBackground} $out/background.png
      '';
    };

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
