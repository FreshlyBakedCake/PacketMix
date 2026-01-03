# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  services.postgres = {
    enable = true;
    initialDatabases = [
      { name = "menu"; }
    ];
  };
}
