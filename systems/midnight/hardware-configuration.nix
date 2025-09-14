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
    device = "/dev/disk/by-uuid/34b14ffd-62b4-4bca-a1b5-349a6eb7cb28";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0CE9-FAD2";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  clicks.storage.impermanence = {
    enable = true;
    devices = {
      root = "/dev/disk/by-uuid/34b14ffd-62b4-4bca-a1b5-349a6eb7cb28";
      persist = "/dev/disk/by-uuid/34b14ffd-62b4-4bca-a1b5-349a6eb7cb28";
    };
  };
  fileSystems."/persist".options = [ "subvol=@persist" ];
}
