# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  networking.networkmanager.enable = true;

  clicks.storage.impermanence.persist.directories = [
    "/etc/NetworkManager"
  ];
}
