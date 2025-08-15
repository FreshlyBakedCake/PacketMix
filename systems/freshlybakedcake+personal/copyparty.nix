# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ pkgs, ... }:
let
  rcloneConfig = builtins.toFile "rclone-freshly.conf" ''
    [freshly]
    type = webdav
    url = https://files.freshly.space
    vendor = owncloud
    pacer_min_sleep = 0.01ms
  '';
  # owncloud is used as a vendor because copyparty recommends it - it activates some features like mtime for servers that support it
  # think how every browser useragent has "Mozilla" in it: https://webaim.org/blog/user-agent-string-history/
in
{
  environment.systemPackages = [ pkgs.rclone ];

  systemd.mounts = [
    {
      description = "Freshly Baked Cake mount";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      what = "freshly:";
      where = "/mnt/freshly";
      options = "x-systemd.automount,uid=1000,gid=100,vfs-cache-mode=writes,dir-cache-time=5s,config=${rcloneConfig},allow-other";
      type = "rclone";
    }
  ];

  systemd.automounts = [
    {
      description = "Freshly Baked Cake automount";
      where = "/mnt/freshly";
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "2m";
      };
    }
  ];
}
