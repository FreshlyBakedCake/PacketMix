# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  environment.systemPackages = [
    project.packages.collabora-gtimelog.result.${system}
  ];
}
