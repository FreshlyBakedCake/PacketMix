# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  services.ssh-agent.enable = true;
  systemd.user.services.ssh-agent.Service.Environment =
    "SSH_ASKPASS=${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/$UID/ssh-agent";
}
