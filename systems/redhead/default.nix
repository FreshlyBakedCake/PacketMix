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
    ./hardware-configuration.nix
    ./hostname.nix
    ./impermanence.nix
    ./nextcloud.nix
    ./office.nix
    ./remoteBuilds.nix
    ./secrets.nix
  ];
}
