# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

let
  pins = import ./npins;

  nilla = import pins.nilla;

  settings = config: {
    nixpkgs = {
      configuration.allowUnfree = true;
      overlays = [
        config.inputs.fenix.result.overlays.default
      ];
    };
    "nixos-24.11" = (settings config).nixpkgs;
    nixos-unstable = (settings config).nixpkgs;
  };

  result = (nilla.create [ ]).extend {
    modules = [
      ./project.nix
      (
        { config, ... }:
        {
          config.inputs = builtins.mapAttrs (name: value: {
            src = value;
            settings = (settings config).${name} or config.lib.constants.undefined;
          }) pins;
        }
      )
    ];

    args = {
      inherit nilla pins; # pins needs to be a static arg for us to import from it...
    };
  };
in
result.config
// {
  extend = result.extend;
}
