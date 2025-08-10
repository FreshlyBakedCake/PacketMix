# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  systemd.user.services.ssh-agent = {
    Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    Unit.After = [ "niri.service" ];
  };

  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [
    "pkcs11"
    "secrets"
  ]; # all excluding ssh
}
