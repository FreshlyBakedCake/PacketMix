# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ ... }:
{
  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=65535
  '';
}
