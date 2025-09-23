# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  systemd.services.tailscale-collabora = {
    after = [ "NetworkManager-wait-online.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.StateDirectory = [ "tailscale/collabora" ];

    script =
      "${pkgs.tailscale}/bin/tailscaled"
      + " -tun=userspace-networking"
      + " -socks5-server=localhost:1055"
      + " -socket=/var/run/tailscale/tailscaled-collabora.sock"
      + " -statedir=/var/lib/tailscale/collabora";
  };

  environment.shellAliases.tailscale-collabora = "${pkgs.tailscale}/bin/tailscale --socket /var/run/tailscale/tailscaled-collabora.sock";
}
