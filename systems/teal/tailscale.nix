# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  networking.hosts."100.64.0.5" = [ "localhost.tailscale" ];

  services.nginx.defaultListenAddresses = [
    "0.0.0.0"
    "[::0]"
    "localhost.tailscale"
  ];
}
