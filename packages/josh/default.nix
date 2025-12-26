# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.josh = {
    systems = [ "x86_64-linux" ];
    package =
      { system, rustPlatform, ... }:
      config.inputs.nixos-unstable.result.${system}.josh.overrideAttrs {
        src = config.inputs.josh.result;

        cargoDeps = rustPlatform.fetchCargoVendor {
          name = "josh";

          src = config.inputs.josh.result;

          hash = "sha256-zY2dCDHhPTggZPhFoONHA4NIpv6k+hzKOUQDzheA/28=";
        };
      };
  };
}
