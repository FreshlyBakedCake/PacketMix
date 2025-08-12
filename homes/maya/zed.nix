# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  programs.zed-editor = {
    userSettings = {
      helix_mode = lib.mkForce false;
      format_on_save = "off";
    };
  };
}
