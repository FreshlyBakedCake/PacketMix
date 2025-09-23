# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # system shellAliases are often disabled in hm-managed shell profiles... so we should copy the alias here too
  home.shellAliases.tailscale-collabora = "${pkgs.tailscale}/bin/tailscale --socket /var/run/tailscale/tailscaled-collabora.sock";
}
