# SPDX-FileCopyrightText: 2020 Nix Community Projects
# SPDX-FileCopyrightText: 2024 Clicks Codes
#
# SPDX-License-Identifier: MIT
# postDeviceCommands based of code from https://github.com/nix-community/impermanence/tree/d5f1ed7141fa407880ff5956ded2c88a307ca940?tab=readme-ov-file#btrfs-subvolumes

{ lib, config, ... }:
let
  cfg = config.clicks.storage.impermanence;
in
{
  options.clicks.storage.impermanence = {
    enable = lib.mkEnableOption "Enable impermanent rootfs with btrfs subvolumes";
    devices = {
      root = lib.mkOption {
        type = lib.types.str;
        description = "Rootfs device path";
      };
      persist = lib.mkOption {
        type = lib.types.str;
        description = "Persistent data device path";
      };
    };
    volumes = {
      mount = lib.mkOption {
        type = lib.types.str;
        description = "Path on rootfs device to the mounting subvolume, everything on here will be deleted";
        default = "@";
      };
      old_roots = lib.mkOption {
        type = lib.types.str;
        description = "Path on rootfs device to store old roots on";
        default = "old_roots";
      };
      persistent_data = lib.mkOption {
        type = lib.types.str;
        description = "Path on persist device to store persistent data on";
        default = "data";
      };
    };
    delete_days = lib.mkOption {
      type = lib.types.int;
      description = "How many days to wait before deleting an old root from `cfg.volumes.old_roots`";
      default = 7;
    };
    persist = {
      directories = lib.mkOption {
        type = lib.types.listOf (
          lib.types.oneOf [
            lib.types.str
            (lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.str
                (lib.types.attrsOf lib.types.str)
              ]
            ))
          ]
        );
        description = "List of directories to store between boots";
        default = [ ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of files to store between boots";
        default = [ ];
      };
    };
  };
  config = lib.mkIf cfg.enable (
    {
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        mkdir /impermanent_fs
        mount ${cfg.devices.root} /impermanent_fs
        if [[ -e /impermanent_fs/${cfg.volumes.mount} ]]; then
            mkdir -p /impermanent_fs/${cfg.volumes.old_roots}
            timestamp=$(date --date="@$(stat -c %Y /impermanent_fs/${cfg.volumes.mount})" "+%Y-%m-%-d_%H:%M:%S")
            mv /impermanent_fs/${cfg.volumes.mount} "/impermanent_fs/${cfg.volumes.old_roots}/$timestamp"
        fi
        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/impermanent_fs/$i"
            done
            btrfs subvolume delete "$1"
        }
        for i in $(find /impermanent_fs/${cfg.volumes.old_roots}/ -maxdepth 1 -mtime +${builtins.toString cfg.delete_days}); do
            delete_subvolume_recursively "$i"
        done
        btrfs subvolume create /impermanent_fs/${cfg.volumes.mount}
        umount /impermanent_fs
      '';
      fileSystems."/" = {
        device = cfg.devices.root;
        fsType = "btrfs";
        options = [ "subvol=${cfg.volumes.mount}" ];
      };
      fileSystems."/persist" = {
        device = cfg.devices.persist;
        neededForBoot = true;
        fsType = "btrfs";
      };
    }
    // {
      environment = lib.optionalAttrs cfg.enable {
        persistence."/persist/${cfg.volumes.persistent_data}" = {
          directories = [
            "/var/lib/nixos" # https://github.com/nix-community/impermanence/issues/178
          ] ++ cfg.persist.directories;
          files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ] ++ cfg.persist.files;
        };
      };
    }
  );
}
