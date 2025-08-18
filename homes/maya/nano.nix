# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  home.sessionVariables = lib.mkForce { EDITOR = "nano"; };
}
