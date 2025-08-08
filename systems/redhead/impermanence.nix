# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  ...
}:
{
  # FIXME: migrate everything to systemd initrd so we can fold into our core impermanence module...
  boot.initrd = {
    postDeviceCommands = lib.mkForce "";
    systemd.services.impermanence =
      let
        cfg = config.clicks.storage.impermanence;
      in
      {
        wantedBy = [
          "initrd.target"
        ];
        before = [
          "sysroot.mount"
        ];
        requires = [
          "dev-disk-by\\x2did-dm\\x2dname\\x2dredhead\\x2dpersist.device"
        ];
        after = [
          "dev-disk-by\\x2did-dm\\x2dname\\x2dredhead\\x2dpersist.device"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
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
      };
    systemd.services.make-home = {
      wantedBy = [
        "initrd.target"
      ];
      requires = [
        "sysroot.mount"
      ];
      after = [
        "sysroot.mount"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /persist/data/home/minion

        chown 1000:100 /persist/data/home/minion # minion:users
        chmod 700 /persist/data/home/minion
      '';
    };
  };

  systemd.services."persist-persist-data-etc-ssh-ssh_host_ed25519_key".preStart =
    "rm /etc/ssh/ssh_host_ed25519_key";
  systemd.services."persist-persist-data-etc-ssh-ssh_host_ed25519_key.pub".preStart =
    "rm /etc/ssh/ssh_host_ed25519_key.pub";
  systemd.services."persist-persist-data-etc-ssh-ssh_host_rsa_key".preStart =
    "rm /etc/ssh/ssh_host_rsa_key";
  systemd.services."persist-persist-data-etc-ssh-ssh_host_rsa_key.pub".preStart =
    "rm /etc/ssh/ssh_host_rsa_key.pub";

  users.mutableUsers = false;
  users.users.minion.hashedPasswordFile = "/persist/data/secrets/impermanence/minion-password.hash"; # cannot do /secrets/impermanence/minion-password.hash because it is loaded too late...
}
