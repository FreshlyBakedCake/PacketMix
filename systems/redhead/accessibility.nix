# SPDX-FileCopyrightText: 2026 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  services.orca.enable = true;

  systemd.user.services.orca = {
    wantedBy = lib.mkForce [ "niri.service" ];
    after = [ "niri.service" ];
  };
}
