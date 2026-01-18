# SPDX-FileCopyrightText: 2025 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  home.packages = [ project.packages.packetmix-vs-launcher.result."x86_64-linux" ];
}
