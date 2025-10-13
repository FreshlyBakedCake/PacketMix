# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  systemd.timers."auto-shutdown" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "* *-*-* 23:55:00 Etc/UTC";
      Persistent = false;
      Unit = "auto-shutdown.service";
    };
  };

  systemd.services."auto-shutdown" = {
    script = ''
      ${pkgs.systemd}/bin/systemctl poweroff
    '';
    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
      User = "root";
    };
  };
}
