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
    device = "/dev/disk/by-uuid/ab5c2f52-a737-4b29-a505-e3d0b9d0714c";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/880D-BBAB";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  boot.swraid.enable = true;

  clicks.storage.impermanence = {
    enable = true;
    devices = {
      root = "/dev/disk/by-uuid/ab5c2f52-a737-4b29-a505-e3d0b9d0714c";
      persist = "/dev/md/a1d1:persist";
    };
  };
}
