# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{
  virtualisation.docker.enable = true;
  users.users.minion.extraGroups = [ "docker" ];

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/docker"
  ];
}
