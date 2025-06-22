# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.openlinkhub = {
    systems = [ "x86_64-linux" ];
    package =
      { openlinkhub, ... }:
      openlinkhub.overrideAttrs (prev: {
        postInstall = ''
          mkdir -p $out/var/lib/OpenLinkHub
          cp -r ${prev.src}/{static,web} $out/var/lib/OpenLinkHub
          mkdir $out/var/lib/OpenLinkHub/database
          cp ${prev.src}/database/rgb.json $out/var/lib/OpenLinkHub/database
          echo "{}" >> $out/var/lib/OpenLinkHub/database/scheduler.json
          cp -r ${prev.src}/database/keyboard $out/var/lib/OpenLinkHub/database

          mkdir -p $out/lib/udev/rules.d
          cp ${prev.src}/99-openlinkhub.rules $out/lib/udev/rules.d
        '';
      });
  };
}
