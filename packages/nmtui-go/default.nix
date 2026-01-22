# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.packetmix-nmtui-go = {
    systems = [ "x86_64-linux" ];
    package =
      {
        lib,
        buildGoModule,
        ...
      }:
      buildGoModule {
        pname = "nmtui-go";
        version = config.inputs.nmtui-go.src.version;
        src = config.inputs.nmtui-go.src;
        vendorHash = "sha256-FYrLLZHd7C98LzmIUuEpJxLEqT2j/7GWHTcjNRRV4xY=";

        postInstall = ''
          mv $out/bin/cmd $out/bin/nmtui-go
        '';

        meta = {
          mainProgram = "nmtui-go";
          maintainer = [ lib.maintainers.minion3665 ];
        };
      };
  };
}
