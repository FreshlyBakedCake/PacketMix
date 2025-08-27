# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.jujutsu = {
    systems = [ "x86_64-linux" ];
    package =
      {
        system,
        ...
      }:
      config.inputs.nixos-unstable.result.${system}.jujutsu.overrideAttrs (prevAttrs: {
        patches = (prevAttrs.patches or [ ]) ++ [ ./7245-jj-gerrit-upload.patch ];
      });
  };
}
