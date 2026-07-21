# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.packetmix-npins = {
    systems = [ "x86_64-linux" ];
    package =
      {
        stdenv,
        ...
      }:
      (config.inputs.npins.result {
        inherit (stdenv.hostPlatform) system;
        pkgs = config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system};
      });
  };
}
