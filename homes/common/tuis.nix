# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  system,
}:
{
  # TUIs for managing various system functions

  home.packages = [
    pkgs.bluetui # Bluetooth
    project.packages.packetmix-nmtui-go.result.${system} # Wi-Fi
  ];

  home.shellAliases = {
    bluetooth = "${pkgs.bluetui}/bin/bluetui";
    nmtui = "${project.packages.packetmix-nmtui-go.result.${system}}/bin/nmtui-go";
    wifi = "${project.packages.packetmix-nmtui-go.result.${system}}/bin/nmtui-go";
  };
}
