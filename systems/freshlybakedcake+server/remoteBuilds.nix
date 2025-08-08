# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  users.users.remoteBuilds = {
    isSystemUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZepe0b+YKW/tdjauBYGFwNRkD0pLEgdRTDB984OuLR redhead"
    ];

    group = "remoteBuilds";
    useDefaultShell = true; # still allow logging in or we can't use this as a remote builder account...
  };
  users.groups.remoteBuilds = { };

  nix.settings.trusted-users = [
    "remoteBuilds"
  ];
}
