# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.davfs2 = {
    enable = true;
    settings.globalSection = {
      # This is the max size of a single file in stalwart
      cache_size = 8192;

      # If we don't do this, we end up with larger files in lost+found
      use_locks = 0;
      drop_weak_etags = 1;
    };
  };

  systemd.mounts = [
    {
      description = "Stalwart dav mount";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      what = "https://mail.freshly.space/dav/file";
      where = "/mnt/freshly";
      options = "x-systemd.automount,uid=1000,gid=100";
      type = "davfs";
    }
  ];

  systemd.automounts = [
    {
      description = "Stalwart dav automount";
      where = "/mnt/freshly";
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "2m";
      };
    }
  ];
}
