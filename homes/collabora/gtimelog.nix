# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  home.packages = [
    project.packages.collabora-gtimelog.result.${system}
  ];

  clicks.storage.impermanence.persist.directories = [
    ".gtimelog"
  ];
}
