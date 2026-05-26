# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  ...
}:
{
  boot.initrd.systemd.services.make-home = {
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
