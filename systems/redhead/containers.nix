# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ project, system, ... }:
{
  # The module for this in nixpkgs seems to use a broken package...
  boot.extraSystemdUnitPaths = [ "/etc/systemd-mutable/system" ];
  environment.systemPackages = [ project.inputs.extra-container.result.packages.${system}.default ];

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/nixos-containers"
    "/etc/systemd-mutable"
  ];
}
