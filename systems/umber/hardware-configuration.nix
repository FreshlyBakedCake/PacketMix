# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "uas"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/2b18af0a-1c4f-4195-8f3f-18a1cc987985";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D50D-92FC";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  clicks.storage.impermanence = {
    enable = true;
    devices = {
      root = "/dev/disk/by-uuid/2b18af0a-1c4f-4195-8f3f-18a1cc987985";
      persist = "/dev/disk/by-uuid/44311fe0-01b9-477b-9626-bf3879bda1da";
    };
  };
}
