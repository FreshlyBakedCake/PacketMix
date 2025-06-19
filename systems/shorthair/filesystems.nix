# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  fileSystems."/" = {
    device = "/dev/mapper/NIXROOT";
    fsType = "btrfs";
  };
  fileSystems."/bigdata" = {
    device = "/dev/mapper/BIGDATA";
    fsType = "btrfs";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F1F9-C8D5";
    fsType = "vfat";
  };
}
