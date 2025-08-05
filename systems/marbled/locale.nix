# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  services.xserver.xkb.variant = lib.mkForce "";
  console.keyMap = lib.mkForce "us";
}
