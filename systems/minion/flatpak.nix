# SPDX-FileCopyrightText: 2025 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{
  services.flatpak.enable = true;

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/flatpak"
  ];
}
