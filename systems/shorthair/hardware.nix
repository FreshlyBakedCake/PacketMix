# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
    "ext4"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "amdgpu"
  ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    systemd.enable = true;
    luks.devices."key".device = "/dev/disk/by-uuid/3ddef258-93b2-459c-9420-121b0631d69a";
    luks.devices."NIXROOT" = {
      device = "/dev/disk/by-uuid/744c83f8-f8d9-4604-8e44-ceb7bf7fdf87";
      keyFile = "/key:/dev/mapper/key";
    };
    luks.devices."BIGDATA" = {
      device = "/dev/disk/by-uuid/640b7c00-5cfa-472f-9338-c7adafa9ea6a";
      keyFile = "/key:/dev/mapper/key";
    };
  };
}
