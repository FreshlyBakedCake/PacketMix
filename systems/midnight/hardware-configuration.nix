# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, config, ... }:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0456a002-1692-4ed0-a233-d6cd76c8c2dd";
    fsType = "btrfs";
  };
  boot.initrd.luks.devices."luks-ssd0".device =
    "/dev/disk/by-uuid/a50b2c75-dd36-4d31-924f-d4b77b94efa9";
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9416-209A";
    fsType = "vfat";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/a1cb08ad-39b3-4a36-bf5a-fad7714a85c0"; } ];
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
