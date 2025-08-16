# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.cifs-utils ];
  users.users.pinea.uid = 1002;
  fileSystems."/mnt/family" = {
    device = "//192.168.0.151/Family";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=/etc/nixos/smb-secrets"
      "uid=${toString config.users.users.pinea.uid}"
      "gid=${toString config.users.groups.users.gid}"
    ];
  };
  fileSystems."/mnt/apricot" = {
    device = "//apricot/main";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=/etc/nixos/smb-secrets-apricot"
      "uid=${toString config.users.users.pinea.uid}"
      "gid=${toString config.users.groups.users.gid}"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /mnt/family 0755 pinea users -"
    "d /mnt/apricot 0755 pinea users -"
  ];
}
