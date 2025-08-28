# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  ...
}:
{
  imports = [
    project.inputs.impermanence.result.nixosModules.impermanence
    ./android.nix
    ./docker.nix
    ./hardware-configuration.nix
    ./hostname.nix
    ./impermanence.nix
    ./nextcloud.nix
    ./office.nix
    ./remoteBuilds.nix
    ./secrets.nix
  ];
}
