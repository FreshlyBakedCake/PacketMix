# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.packetmix-josh = {
    systems = [ "x86_64-linux" ];
    package =
      { stdenv, rustPlatform, ... }:
      config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.josh.overrideAttrs {
        src = config.inputs.josh.result;

        cargoDeps = rustPlatform.fetchCargoVendor {
          name = "josh";

          src = config.inputs.josh.result;

          hash = "sha256-zY2dCDHhPTggZPhFoONHA4NIpv6k+hzKOUQDzheA/28=";
        };
      };
  };
}
