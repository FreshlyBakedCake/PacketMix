# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  systemd.user.services.ssh-agent = {
    Install.WantedBy = lib.mkForce [ "niri.service" ];
    Unit.After = [ "niri.service" ];
  };
}
