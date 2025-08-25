# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

let
  base = import ./nilla.nix;
  project = base.extend {
    modules = [
      (
        { config, lib, ... }:
        {
          config.inputs = (
            builtins.mapAttrs (
              name: value:
              if value ? settings.configuration.allowUnfree then
                {
                  settings.configuration = {
                    allowUnfree = false;
                    allowUnfreePredicate = (
                      x: (x ? meta.license) && (x.meta.license.shortName == "unfreeRedistributable")
                    ); # As we push to a public cachix, we can't use non-redistributable unfree software in CI
                  };
                }
              else
                { }
            ) base.inputs
          );
        }
      )
      {
        config.lib.ci = true;
      }
    ];
  };
in
project.config // { inherit (project) extend; }
